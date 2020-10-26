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

    args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

    # use the built-in error checking
    # if !runner.validateUserArguments(arguments(model), user_arguments)
      # return false
    # end
 
	
	#Identify key names for output variables. 
	plantloops = model.getPlantLoops

    selected_plant_loops = []
    i = 0
	
	variable_name1 = 'System Node Mass Flow Rate'
	variable_name2 = 'System Node Temperature'
	reporting_frequency = 'hourly'

    plantloops.each do |plantLoop|
	  if plantLoop.name.get.to_s.downcase.include? "chilled" 
	     #Extract plant loop information 
         selected_plant_loops[0]=plantLoop
		 key_value_chw_outlet = selected_plant_loops[0].demandOutletNode.name.to_s
	     key_value_chw_inlet = selected_plant_loops[0].demandInletNode.name.to_s
		 #Add desired output variables. Automate this process better in the future. 
		 outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
         outputVariable.setReportingFrequency(reporting_frequency)
	     outputVariable.setKeyValue(key_value_chw_outlet)
	     outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
         outputVariable.setReportingFrequency(reporting_frequency)
	     outputVariable.setKeyValue(key_value_chw_inlet)
		 outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
         outputVariable.setReportingFrequency(reporting_frequency)
	     outputVariable.setKeyValue(key_value_chw_outlet)
	     outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
         outputVariable.setReportingFrequency(reporting_frequency)
	     outputVariable.setKeyValue(key_value_chw_inlet)
      end 
	  if plantLoop.name.get.to_s.downcase.include? "hot" 
	     #Extract plant loop information 
		 selected_plant_loops[1]=plantLoop
		 key_value_hhw_outlet = selected_plant_loops[1].demandOutletNode.name.to_s
	     key_value_hhw_inlet = selected_plant_loops[1].demandInletNode.name.to_s
		 #Add desired output variables. Automate this process better in the future. 
         outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
         outputVariable.setReportingFrequency(reporting_frequency)
		 outputVariable.setKeyValue(key_value_hhw_outlet)
		 outputVariable = OpenStudio::Model::OutputVariable.new(variable_name1, model)
		 outputVariable.setReportingFrequency(reporting_frequency)
		 outputVariable.setKeyValue(key_value_hhw_inlet)
		 outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
         outputVariable.setReportingFrequency(reporting_frequency)
	     outputVariable.setKeyValue(key_value_hhw_outlet)
	     outputVariable = OpenStudio::Model::OutputVariable.new(variable_name2, model)
         outputVariable.setReportingFrequency(reporting_frequency)
	     outputVariable.setKeyValue(key_value_hhw_inlet)
     end 
   end 
   
   if selected_plant_loops[1].nil?
	  runner.registerWarning("No hot water loop found. If a hot loop should be present, verify that its name includes the word 'hot.'") 
   end 
   
   if selected_plant_loops[0].nil?
   	     runner.registerWarning("No chilled water loop found. If a chilled water loop should be present, verify that its name includes the word 'chilled.'") 
   end 
   
   if selected_plant_loops.empty?
       runner.registerError("No plant loops for heating or cooling found, so no output variables have been added. See warning messages for loop 
	   naming requirements.") 
   end 


    return true
  end
end
AddOutputVariablesforHydronicHVACSystems.new.registerWithApplication