# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2020, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

require 'erb'


# start the measure
class ExportTimeSeriesLoadsCSV < OpenStudio::Measure::ReportingMeasure
  Dir[File.dirname(__FILE__) + '/resources/*.rb'].each { |file| require file }
  include OsLib_HelperMethods
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    'ExportTimeSeriesLoadsCSV'
  end

  def description
    'This measure will add the required output variables and create a CSV file with plant loop level mass flow rates and temperatures for use in a Modelica simulation. Note that this measure has certain
	 requirements for naming of hydronic loops (discussed in the modeler description section).'
  end

  def modeler_description
    'This measure is currently configured to report the temperatures and mass flow rates at the demand outlet and inlet nodes of hot water and chilled water loops, after adding the required output variables to the model. These values can be used to calculate the sum of the demand-side loads, and could thus represent the load on a connection to a district thermal energy system, or on
	building-level primary equipment. This measure assumes that the model includes hydronic HVAC loops, and that the hot water and chilled water loop names can each be uniquely identified by a user-provided string. This measure also assumes that there is a single heating hot water loop
	and a single chilled-water loop per building.'
  end

  def log(str)
    puts "#{Time.now}: #{str}"
  end

  def arguments(_model) 
    args = OpenStudio::Measure::OSArgumentVector.new
	
    hhw_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('hhw_loop_name', true)
    hhw_loop_name.setDisplayName('Name or Partial Name of Heating Hot Water Loop, non-case-sensitive')
    hhw_loop_name.setDefaultValue('hot')
    args << hhw_loop_name
	
	chw_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('chw_loop_name', true)
    chw_loop_name.setDisplayName('Name or Partial Name of Chilled Water Loop, non-case-sensitive')
    chw_loop_name.setDefaultValue('chilled')
    args << chw_loop_name
	
	dec_places_mass_flow = OpenStudio::Measure::OSArgument.makeIntegerArgument('dec_places_mass_flow', true)
    dec_places_mass_flow.setDisplayName('Number of Decimal Places to Round Mass Flow Rate')
    dec_places_mass_flow.setDescription('Number of decimal places to which mass flow rate will be rounded')
    dec_places_mass_flow.setDefaultValue(3)
    args << dec_places_mass_flow
	
    dec_places_temp = OpenStudio::Measure::OSArgument.makeIntegerArgument('dec_places_temp', true)
    dec_places_temp.setDisplayName('Number of Decimal Places to Round Temperature')
    dec_places_temp.setDescription('Number of decimal places to which temperature will be rounded')
    dec_places_temp.setDefaultValue(1)
    args << dec_places_temp

    return args
  end

  # return a vector of IdfObject's to request EnergyPlus objects needed by the run method
  def energyPlusOutputRequests(runner, user_arguments)
    super(runner, user_arguments)

    result = OpenStudio::IdfObjectVector.new
	

    # To use the built-in error checking we need the model...
    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    # use the built-in error checking
    return false unless runner.validateUserArguments(arguments(model), user_arguments)
	
	##Read in argumetns related to variables for output requests 
	hhw_loop_name = runner.getStringArgumentValue('hhw_loop_name', user_arguments)
	chw_loop_name = runner.getStringArgumentValue('chw_loop_name', user_arguments)
	

	#Identify key names for output variables. 
	plantloops = model.getPlantLoops

    selected_plant_loops = []
    i = 0
	
	variable_name1 = 'System Node Mass Flow Rate'
	variable_name2 = 'System Node Temperature'
	reporting_frequency = 'timestep' 

	
    plantloops.each do |plantLoop|
	  log "plant loop name #{plantLoop.name.get.to_s}"
	  if plantLoop.name.get.to_s.downcase.include? chw_loop_name.to_s
	     #Extract plant loop information 
         selected_plant_loops[0]=plantLoop
		 key_value_chw_outlet = selected_plant_loops[0].demandOutletNode.name.to_s
	     key_value_chw_inlet = selected_plant_loops[0].demandInletNode.name.to_s
		 result << OpenStudio::IdfObject.load("Output:Variable,#{key_value_chw_outlet},#{variable_name2},timestep;").get 
		 result << OpenStudio::IdfObject.load("Output:Variable,#{key_value_chw_inlet},#{variable_name2},timestep;").get 
         result << OpenStudio::IdfObject.load("Output:Variable,#{key_value_chw_outlet},#{variable_name1},timestep;").get 
      end 
	  if plantLoop.name.get.to_s.downcase.include? hhw_loop_name.to_s and !plantLoop.name.get.to_s.downcase.include? "service" and !plantLoop.name.get.to_s.downcase.include? "domestic"
	     #Extract plant loop information 
		 selected_plant_loops[1]=plantLoop
		 key_value_hhw_outlet = selected_plant_loops[1].demandOutletNode.name.to_s
	     key_value_hhw_inlet = selected_plant_loops[1].demandInletNode.name.to_s
		 result << OpenStudio::IdfObject.load("Output:Variable,#{key_value_hhw_outlet},#{variable_name2},timestep;").get 
		 result << OpenStudio::IdfObject.load("Output:Variable,#{key_value_hhw_inlet},#{variable_name2},timestep;").get 
         result << OpenStudio::IdfObject.load("Output:Variable,#{key_value_hhw_outlet},#{variable_name1},timestep;").get 
     end 
   end 
   

    result << OpenStudio::IdfObject.load('Output:Variable,,Site Mains Water Temperature,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Site Outdoor Air Drybulb Temperature,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Variable,,Site Outdoor Air Relative Humidity,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Cooling:Electricity,hourly;').get
	result << OpenStudio::IdfObject.load('Output:Meter,Cooling:Electricity,timestep;').get ##Using this for data at timestep interval 
    result << OpenStudio::IdfObject.load('Output:Meter,Heating:Electricity,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Heating:Gas,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,InteriorLights:Electricity,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,Fans:Electricity,hourly;').get
    result << OpenStudio::IdfObject.load('Output:Meter,InteriorEquipment:Electricity,hourly;').get # Joules
    result << OpenStudio::IdfObject.load('Output:Meter,ExteriorLighting:Electricity,hourly;').get # Joules
    result << OpenStudio::IdfObject.load('Output:Meter,Electricity:Facility,hourly;').get # Joules
    result << OpenStudio::IdfObject.load('Output:Meter,Gas:Facility,hourly;').get # Joules
    result << OpenStudio::IdfObject.load('Output:Meter,Heating:EnergyTransfer,hourly;').get # Joules
    result << OpenStudio::IdfObject.load('Output:Meter,WaterSystems:EnergyTransfer,hourly;').get # Joules
    # these variables are used for the modelica export.
    result << OpenStudio::IdfObject.load('Output:Variable,*,Zone Predicted Sensible Load to Setpoint Heat Transfer Rate,hourly;').get # watts according to e+
    result << OpenStudio::IdfObject.load('Output:Variable,*,Water Heater Total Demand Heat Transfer Rate,hourly;').get # Watts

    result
  end

  def extract_timeseries_into_matrix(sqlfile, data, variable_name, str, key_value = nil, default_if_empty = 0,dec_places, timestep) 
    log "Executing query for #{variable_name}"
    #column_name = variable_name
    if key_value
      #ts = sqlfile.timeSeries('RUN PERIOD 1', 'Hourly', variable_name, key_value) 
      ts = sqlfile.timeSeries('RUN PERIOD 1', 'Zone Timestep', variable_name, key_value) 
      #column_name += "_#{key_value}"
	  column_name=str
    else
      #ts = sqlfile.timeSeries('RUN PERIOD 1', 'Hourly', variable_name)
      ts = sqlfile.timeSeries('RUN PERIOD 1', 'Zone Timestep', variable_name) 
    end
    log 'Iterating over timeseries'
    column = [column_name.delete(':').delete(' ')] # Set the header of the data to the variable name, removing : and spaces

    if ts.empty?
      log "No time series for #{variable_name}:#{key_value}... defaulting to #{default_if_empty}"
      # needs to be data.size-1 since the column name is already stored above (+=)
      column += [default_if_empty] * (data.size - 1)
    else
      ts = ts.get if ts.respond_to?(:get)
      ts = ts.first if ts.respond_to?(:first)
	  
      start = Time.now
      # Iterating in OpenStudio can take up to 60 seconds with 10min data. The quick_proc takes 0.03 seconds.
      # for i in 0..ts.values.size - 1
      #   log "... at #{i}" if i % 10000 == 0
      #   column << ts.values[i]
      # end

      quick_proc = ts.values.to_s.split(',')
	  quick_proc[0]=quick_proc[0].split('(', 2).last #cleanup necessary to remove opening paren 
	  quick_proc=quick_proc.map(&:to_f) 
	  x = 0
      len = quick_proc.length
	  log "quick proc #{quick_proc}" 
      while(x < len) #Round to the # of decimal places specified 
          quick_proc[x]=(quick_proc[x]).round(dec_places)
          x=x+1
	  end 
	  quick_proc=quick_proc.map(&:to_s)

	  
      # the first and last have some cleanup items because of the Vector method
      quick_proc[0] = quick_proc[0].gsub(/^.*\(/, '') 
      quick_proc[-1] = quick_proc[-1].delete(')') 
      column += quick_proc
	  
	  

      log "Took #{Time.now - start} to iterate"
    end

    log 'Appending column to data'

    # append the data to the end of the rows
    if column.size == data.size
      data.each_index do |index|
        data[index] << column[index]
      end
    end

    log "Finished extracting #{variable_name}"
  end

  def create_new_variable_sum(data, new_var_name, include_str, options=nil)
    var_info = {
      name: new_var_name,
      var_indexes: []
    }
    data.each_with_index do |row, index|
      if index.zero?
        # Get the index of the columns to add
        row.each do |c|
          var_info[:var_indexes] << row.index(c) if c.include? include_str
        end

        # add the new var to the header row
        data[0] << var_info[:name]
      else
        # sum the values
        sum = 0
        var_info[:var_indexes].each do |var|
          temp_v = row[var].to_f
          if options.nil?
            sum += temp_v
          elsif options[:positive_only] && temp_v > 0
            sum += temp_v
          elsif options[:negative_only] && temp_v < 0
            sum += temp_v
          end
        end
        data[index] << sum
      end
    end
  end

  def run(runner, user_arguments)
    super(runner, user_arguments)

    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get

    # use the built-in error checking
    return false unless runner.validateUserArguments(arguments(model), user_arguments)
	
	args = OsLib_HelperMethods.createRunVariables(runner, model, user_arguments, arguments(model))
	if !args then return false end

    # lookup and replace argument values from upstream measures
    if args['use_upstream_args'] == true
      args.each do |arg,value|
        next if arg == 'use_upstream_args' # this argument should not be changed
        value_from_osw = OsLib_HelperMethods.check_upstream_measure_for_arg(runner, arg)
        if !value_from_osw.empty?
          runner.registerInfo("Replacing argument named #{arg} from current measure with a value of #{value_from_osw[:value]} from #{value_from_osw[:measure_name]}.")
          new_val = value_from_osw[:value]
          # todo - make code to handle non strings more robust. check_upstream_measure_for_arg could pass bakc the argument type
          if arg == 'hhw_loop_name'
            args[arg] = new_val.to_s
          elsif arg == 'chw_loop_name'
            args[arg] = new_val.to_s
          else
            args[arg] = new_val
          end
        end
      end
    end
    hhw_loop_name = args['hhw_loop_name']
	chw_loop_name = args['chw_loop_name']
	dec_places_temp = args['dec_places_temp']
	dec_places_mass_flow = args['dec_places_mass_flow']
    # get the last model and sql file
    model = runner.lastOpenStudioModel
    if model.empty?
      runner.registerError('Cannot find last model.')
      return false
    end
    model = model.get
	

	timesteps_per_hour=model.getTimestep.numberOfTimestepsPerHour.to_i
	timestep=60/timesteps_per_hour #timestep in minutes 

    sqlFile = runner.lastEnergyPlusSqlFile
    if sqlFile.empty?
      runner.registerError('Cannot find last sql file.')
      return false
    end
    sqlFile = sqlFile.get
    model.setSqlFile(sqlFile)

    # create a new csv with the values and save to the reports directory.
    # assumptions:
    #   - all the variables exist
    #   - data are the same length

    # initialize the rows with the header
    log 'Starting to process Timeseries data'
    # Initial header row
    rows = [
      ['Date Time', 'Month', 'Day', 'Day of Week', 'Hour', 'Minute', 'SecondsFromStart']
    ]

    # just grab one of the variables to get the date/time stamps
    ts = sqlFile.timeSeries('RUN PERIOD 1', 'Zone Timestep', 'Cooling:Electricity')
	#ts = sqlFile.timeSeries('RUN PERIOD 1', 'Hourly', 'Cooling:Electricity')
	unless ts.empty? 
      ts = ts.first
      dt_base = nil
      # Save off the date time values
      ts.dateTimes.each_with_index do |dt, index|
        dt_base = DateTime.parse(dt.to_s) if dt_base.nil?
        dt_current = DateTime.parse(dt.to_s)
        rows << [
          DateTime.parse(dt.to_s).strftime('%m/%d/%Y %H:%M'),
          dt.date.monthOfYear.value,
          dt.date.dayOfMonth,
          dt.date.dayOfWeek.value,
          dt.time.hours,
          dt.time.minutes,
          dt_current.to_time.to_i - dt_base.to_time.to_i + timestep*60 
        ]
      end
    end

    plantloops = model.getPlantLoops

    selected_plant_loops = []
    i = 0
	
	key_var={}

    plantloops.each do |plantLoop|
	  if plantLoop.name.get.to_s.downcase.include? chw_loop_name.to_str
	     #Extract plant loop information 
         selected_plant_loops[0]=plantLoop
	  end 
	  if plantLoop.name.get.to_s.downcase.include? hhw_loop_name.to_str
         #Get plant loop information
		 selected_plant_loops[1]=plantLoop
	  end 
    end
	
	if !selected_plant_loops[1].nil?
	 #Set up variables for output 
	 key_value_hhw_outlet = selected_plant_loops[1].demandOutletNode.name.to_s
	 key_value_hhw_inlet = selected_plant_loops[1].demandInletNode.name.to_s
	 key_var['hhw_outlet_massflow']='massFlowRateHeating'
	 key_var['hhw_outlet_temp']='heatingReturnTemperature[C]'
	 key_var['hhw_inlet_temp']='heatingSupplyTemperature[C]'
	 #Extract time series 
	 extract_timeseries_into_matrix(sqlFile, rows, 'System Node Temperature', key_var['hhw_outlet_temp'], key_value_hhw_outlet, 0, dec_places_temp, timestep) 
	 extract_timeseries_into_matrix(sqlFile, rows, 'System Node Temperature', key_var['hhw_inlet_temp'], key_value_hhw_inlet, 0, dec_places_temp, timestep)
	 extract_timeseries_into_matrix(sqlFile, rows, 'System Node Mass Flow Rate', key_var['hhw_outlet_massflow'], key_value_hhw_outlet, 0, dec_places_mass_flow, timestep) 
	 else 
		runner.registerWarning("No hot water loop found. If one is expected, make sure the hot water loop name argument provides a string present in its name.") 
     end 
	
	if !selected_plant_loops[0].nil?
	 #Set up variables for outputs 
	 key_value_chw_outlet = selected_plant_loops[0].demandOutletNode.name.to_s
	 key_value_chw_inlet = selected_plant_loops[0].demandInletNode.name.to_s
	 key_var['chw_outlet_massflow']='massFlowRateCooling'
	 key_var['chw_outlet_temp']='ChilledWaterReturnTemperature[C]'
	 key_var['chw_inlet_temp']='ChilledWaterSupplyTemperature[C]'
	 #Extract time series 
	 extract_timeseries_into_matrix(sqlFile, rows, 'System Node Temperature', key_var['chw_outlet_temp'], key_value_chw_outlet, 0, dec_places_temp,timestep)
	 extract_timeseries_into_matrix(sqlFile, rows, 'System Node Temperature', key_var['chw_inlet_temp'], key_value_chw_inlet, 0, dec_places_temp,timestep) 
	 extract_timeseries_into_matrix(sqlFile, rows, 'System Node Mass Flow Rate', key_var['chw_outlet_massflow'], key_value_chw_outlet, 0, dec_places_mass_flow,timestep)
	else 
	     runner.registerWarning("No chilled water loop found. If one is expected, make sure the chilled water loop name argument provides a string present in its name.") 
    end 
	
   
   if selected_plant_loops[0].nil? and selected_plant_loops[1].nil?
    runner.registerWarning("No HVAC plant loops found. If one or more plant loops are expected, make sure they follow the naming conventions mentioned in the previous warnings.") 
   end 
   
   if !selected_plant_loops.nil?
    # convert this to CSV object
    File.open('./building_loads.csv', 'w') do |f|
      rows.each do |row|
        f << row.join(',') << "\n"
      end
	end 
   end 

    true
  ensure
    sqlFile&.close
  end
  end 


# register the measure to be used by the application
ExportTimeSeriesLoadsCSV.new.registerWithApplication
