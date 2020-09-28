# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class AddOutputVariablesforHydronicHVACSystems < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Add Output Variables for Hydronic HVAC Systems'
  end

  # human readable description
  def description
    return 'This measure adds output variables for temperature and mass flow rate at the demand inlet node for hydronic HVAC loops. This measure can be used to generate a time series for modeling a building load attached to a district thermal energy system.'
  end 
  # human readable description of modeling approach
  def modeler_description
    return 'This measure requires that heating hot water and chilled water loops (one of each) be present in the model, and that the heating hot water loop have the word "hot" in its name, and that the chilled water loop have the word "chilled" in its name (non case sensitive). 
	This measure will be modified in the future to be more generic.'
  end

  # define the arguments that the user will input
  def arguments(_model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # # the name of the space to add to the model
    # space_name = OpenStudio::Measure::OSArgument.makeStringArgument('space_name', true)
    # space_name.setDisplayName('New space name')
    # space_name.setDescription('This name will be used as the name of the new space.')
    # args << space_name

    args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    # if !runner.validateUserArguments(arguments(model), user_arguments)
      # return false
    # end
    
    # # assign the user inputs to variables
    # space_name = runner.getStringArgumentValue('space_name', user_arguments)

    # # check the space_name for reasonableness
    # if space_name.empty?
      # runner.registerError('Empty space name was entered.')
      # return false
    # end

    # # report initial condition of model
    # runner.registerInitialCondition("The building started with #{model.getSpaces.size} spaces.")

    # # add a new space to the model
    # new_space = OpenStudio::Model::Space.new(model)
    # new_space.setName(space_name)

    # # echo the new space's name back to the user
    # runner.registerInfo("Space #{new_space.name} was added.")

    # # report final condition of model
    # runner.registerFinalCondition("The building finished with #{model.getSpaces.size} spaces.")
	
	#Identify key names for output variables. 
	plantloops = model.getPlantLoops

    selected_plant_loops = []
    i = 0

    plantloops.each do |plantLoop|
	  if plantLoop.name.get.to_s.downcase.include? "chilled" 
         selected_plant_loops[0]=plantLoop
      end 
	  if plantLoop.name.get.to_s.downcase.include? "hot" 
         # hhw_demand_outlet_node_name = plantLoop.demandOutletNode.name
		 # hhw_demand_inlet_node_name = plantLoop.demandInletNode.name
		 selected_plant_loops[1]=plantLoop
		 # runner.registerInfo("Plant loop name #{plantLoop.name}")
		 #runner.registerInfo("HHW demand outlet node name: #{hhw_demand_outlet_node_name.to_s}")
      end 
    end
	
	#Generate output variables
    key_value_hhw_outlet = selected_plant_loops[1].demandOutletNode.name.to_s
	key_value_hhw_inlet = selected_plant_loops[1].demandInletNode.name.to_s
	key_value_chw_outlet = selected_plant_loops[0].demandOutletNode.name.to_s
	key_value_chw_inlet = selected_plant_loops[0].demandInletNode.name.to_s
	
	
    variable_name1 = 'System Node Mass Flow Rate'
	variable_name2 = 'System Node Temperature'
	reporting_frequency = 'hourly'
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_hhw_outlet)
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_hhw_inlet)
	
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_chw_outlet)
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_chw_inlet)
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_hhw_outlet)
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_hhw_inlet)
	
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_chw_outlet)
	
	outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
    outputVariable.setReportingFrequency(reporting_frequency)
	outputVariable.setKeyValue(key_value_chw_inlet)
	
	

    return true
  end
end
AddOutputVariablesforHydronicHVACSystems.new.registerWithApplication
