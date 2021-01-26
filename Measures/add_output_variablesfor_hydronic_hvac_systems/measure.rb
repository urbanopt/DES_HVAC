# URBANopt, Copyright (c) 2019-2020, Alliance for Sustainable Energy, LLC, and other contributors.
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted
# provided that the following conditions are met:

# Redistributions of source code must retain the above copyright notice, this list of conditions
# and the following disclaimer.

# Redistributions in binary form must reproduce the above copyright notice, this list of conditions
# and the following disclaimer in the documentation and/or other materials provided with the
# distribution.

# Neither the name of the copyright holder nor the names of its contributors may be used to endorse
# or promote products derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
# OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new
	
    hhw_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('hhw_loop_name', true)
    hhw_loop_name.setDisplayName('Name or Partial Name of Heating Hot Water Loop, non-case-sensitive')
    hhw_loop_name.setDefaultValue('hot')
    args << hhw_loop_name
	
	chw_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('chw_loop_name', true)
    chw_loop_name.setDisplayName('Name or Partial Name of Chilled Water Loop, non-case-sensitive')
    chw_loop_name.setDefaultValue('chilled')
    args << chw_loop_name

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
	
    #use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end
	
	hhw_loop_name = runner.getStringArgumentValue('hhw_loop_name', user_arguments)
	chw_loop_name = runner.getStringArgumentValue('chw_loop_name', user_arguments)
	

	#Identify key names for output variables. 
	plantloops = model.getPlantLoops

    selected_plant_loops = []
    i = 0
	
	variable_name1 = 'System Node Mass Flow Rate'
	variable_name2 = 'System Node Temperature'
	#reporting_frequency = 'hourly' ##need to make this match the timestep in the model 
	reporting_frequency = 'timestep' 

	
    plantloops.each do |plantLoop|
	  if plantLoop.name.get.to_s.downcase.include? chw_loop_name.to_s
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
	  if plantLoop.name.get.to_s.downcase.include? hhw_loop_name.to_s and !plantLoop.name.get.to_s.downcase.include? "service" and !plantLoop.name.get.to_s.downcase.include? "domestic"
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
	  runner.registerWarning("No hot water loop found. If a hot loop should be present, verify that the hot water loop name argument provides a string present in its name.") 
   end 
   
   if selected_plant_loops[0].nil?
   	     runner.registerWarning("No chilled water loop found. If a chilled water loop should be present, verify that the chilled water loop name argument provides a string present in its name.") 
   end 
   
   if selected_plant_loops.empty?
       runner.registerWarning("No plant loops for heating or cooling found, so no output variables have been added. See previous warning messages for loop 
	   naming requirements.") 
   end 


    return true
  end
end
AddOutputVariablesforHydronicHVACSystems.new.registerWithApplication
