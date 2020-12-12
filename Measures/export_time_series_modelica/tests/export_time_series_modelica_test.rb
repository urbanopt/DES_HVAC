# insert your copyright here

require 'openstudio'
require 'openstudio/measure/ShowRunnerOutput'
require 'minitest/autorun'
require_relative '../measure.rb'
require 'fileutils'

class ExportTimeSeriesModelicaTest < Minitest::Test
  def model_in_path_default
    return "#{File.dirname(__FILE__)}/example_model.osm"
  end

  def epw_path_default
    # make sure we have a weather data location
    epw = File.expand_path("#{File.dirname(__FILE__)}/USA_CO_Golden-NREL.724666_TMY3.epw")
    assert(File.exist?(epw.to_s))
    return epw.to_s
  end

  def run_dir(test_name)
    # always generate test output in specially named 'output' directory so result files are not made part of the measure
    return "#{File.dirname(__FILE__)}/output/#{test_name}"
  end

  def model_out_path(test_name)
    return "#{run_dir(test_name)}/example_model.osm"
  end

  def sql_path(test_name)
    return "#{run_dir(test_name)}/run/eplusout.sql"
  end

  def report_path(test_name)
    return "#{run_dir(test_name)}/report.html"
  end

  # method for running the test simulation using OpenStudio 2.x API
  def setup_test_2(test_name, epw_path)
    osw_path = File.join(run_dir(test_name), 'in.osw')
    osw_path = File.absolute_path(osw_path)

    workflow = OpenStudio::WorkflowJSON.new
    workflow.setSeedFile(File.absolute_path(model_out_path(test_name)))
    workflow.setWeatherFile(File.absolute_path(epw_path))
    workflow.saveAs(osw_path)

    cli_path = OpenStudio.getOpenStudioCLI
    cmd = "\"#{cli_path}\" run -w \"#{osw_path}\""
    puts cmd
    system(cmd)
  end

  # create test files if they do not exist when the test first runs
  def setup_test(test_name, idf_output_requests, model_in_path = model_in_path_default, epw_path = epw_path_default)
    if !File.exist?(run_dir(test_name))
      FileUtils.mkdir_p(run_dir(test_name))
    end
    assert(File.exist?(run_dir(test_name)))

    if File.exist?(report_path(test_name))
      FileUtils.rm(report_path(test_name))
    end

    assert(File.exist?(model_in_path))

    if File.exist?(model_out_path(test_name))
      FileUtils.rm(model_out_path(test_name))
    end

    # convert output requests to OSM for testing, OS App and PAT will add these to the E+ Idf
    workspace = OpenStudio::Workspace.new('Draft'.to_StrictnessLevel, 'EnergyPlus'.to_IddFileType)
    workspace.addObjects(idf_output_requests)
    rt = OpenStudio::EnergyPlus::ReverseTranslator.new
    request_model = rt.translateWorkspace(workspace)

    translator = OpenStudio::OSVersion::VersionTranslator.new
    model = translator.loadModel(model_in_path)
    assert(!model.empty?)
    model = model.get
    model.addObjects(request_model.objects)
    model.save(model_out_path(test_name), true)

    if ENV['OPENSTUDIO_TEST_NO_CACHE_SQLFILE']
      if File.exist?(sql_path(test_name))
        FileUtils.rm_f(sql_path(test_name))
      end
    end

    setup_test_2(test_name, epw_path)
  end

  def test_number_of_arguments_and_argument_names
    # create an instance of the measure
    measure = ExportTimeSeriesLoadsCSV.new

    # Make an empty model
    model = OpenStudio::Model::Model.new

    # get arguments and test that they are what we are expecting
    arguments = measure.arguments(model)
    assert_equal(4, arguments.size)
  end

  def test_good_argument_values
    test_name = 'test_good_argument_values'

    # create an instance of the measure
    measure = ExportTimeSeriesLoadsCSV.new

    # create runner with empty OSW
    osw = OpenStudio::WorkflowJSON.new
    runner = OpenStudio::Measure::OSRunner.new(osw)

    # load the test model
    translator = OpenStudio::OSVersion::VersionTranslator.new
    path = "#{File.dirname(__FILE__)}/example_model.osm"
    model = translator.loadModel(path)
    assert(!model.empty?)
    model = model.get

    # store the number of spaces in the seed model
    num_spaces_seed = model.getSpaces.size

    # get arguments
    arguments = measure.arguments(model)
    argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # create hash of argument values.
    # If the argument has a default that you want to use, you don't need it in the hash
    args_hash = {}
    #args_hash['space_name'] = 'New Space'
    # using defaults values from measure.rb for other arguments

    # populate argument with specified hash value if specified
    arguments.each do |arg|
      temp_arg_var = arg.clone
      if args_hash.key?(arg.name)
        assert(temp_arg_var.setValue(args_hash[arg.name]))
      end
      argument_map[arg.name] = temp_arg_var
    end

    model_path='C:\Users\User\Documents\GitHub\OpenStudio-measures\lib\measures\export_time_series_modelica\tests\example_model.osm'
    #runner.setLastOpenStudioModelPath(model_out_path(test_name)) ##AA added 
	sql_path='C:/Users/User/Documents/GitHub/OpenStudio-measures/lib/measures/export_time_series_modelica/tests/output/test_good_argument_values/run/eplusout.sql'
	#runner.setLastEnergyPlusSqlFilePath("#{File.dirname(__FILE__)}") ##AA commented out 
	runner.setLastEnergyPlusSqlFilePath(sql_path)
	runner.setLastOpenStudioModelPath(path)
	
    idf_output_requests = measure.energyPlusOutputRequests(runner, argument_map) ##AA added this 
  

    # mimic the process of running this measure in OS App or PAT. Optionally set custom model_in_path and custom epw_path.
    epw_path = epw_path_default
    setup_test(test_name, idf_output_requests)
	
    # run the measure
    measure.run(runner, argument_map) ##AA modified for this measure 
    result = runner.result

    # show the output
    show_output(result)

    # assert that it ran correctly
    assert_equal('Success', result.value.valueName)

    # create runner with empty OSW
    # osw = OpenStudio::WorkflowJSON.new
    # runner = OpenStudio::Measure::OSRunner.new(osw)

    # # Make an empty model
    # model = OpenStudio::Model::Model.new

    # # get arguments
    # arguments = measure.arguments(model)
    # argument_map = OpenStudio::Measure.convertOSArgumentVectorToMap(arguments)

    # # get the energyplus output requests, this will be done automatically by OS App and PAT
    # # idf_output_requests = measure.energyPlusOutputRequests(runner, argument_map)
    # # assert_equal(1, idf_output_requests.size)

    # # mimic the process of running this measure in OS App or PAT. Optionally set custom model_in_path and custom epw_path.
    # epw_path = epw_path_default
    # # setup_test(test_name, idf_output_requests)
	# setup_test_2(test_name, epw_path) ##AA added

    # assert(File.exist?(model_out_path(test_name)))
    # assert(File.exist?(sql_path(test_name)))
    # assert(File.exist?(epw_path))

    # # set up runner, this will happen automatically when measure is run in PAT or OpenStudio
    # runner.setLastOpenStudioModelPath(model_out_path(test_name))
    # runner.setLastEpwFilePath(epw_path)
    # runner.setLastEnergyPlusSqlFilePath(sql_path(test_name))

    # # delete the output if it exists
    # if File.exist?(report_path(test_name))
      # FileUtils.rm(report_path(test_name))
    # end
    # assert(!File.exist?(report_path(test_name)))

    # # temporarily change directory to the run directory and run the measure
    # start_dir = Dir.pwd
    # begin
      # Dir.chdir(run_dir(test_name))

      # # run the measure
      # measure.run(runner, argument_map)
      # result = runner.result
      # show_output(result)
      # assert_equal('Success', result.value.valueName)
      # assert(result.warnings.empty?)
    # ensure
      # Dir.chdir(start_dir)
    # end

    # # make sure the report file exists
    # assert(File.exist?(report_path(test_name)))
  end
   
end

