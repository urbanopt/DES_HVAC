# DES_HVAC
Repository for scripts related to modeling of different HVAC systems for buildings in a district served by a district thermal energy system. 

# Test Suite
The test suite is a project for the Parametric Analysis Tool, in which one can apply the measures in this repo to a model (such as one created by the Create DOE Prototype Building measure) to test them. 

Expected behavior from tests: 

-If the building model contains a hydronic HVAC system (with the heating loop having "Hot" in its name and the cooling loop having "Chilled" in its name)":
   Applying the Add Output Variables measure, and then Export Time Series to Modelica (in that sequence) should work successfully to generate a time series file of loads (temperatures and mass flow rates for the building-level hydronic HVAC system) for Modelica model of a district thermal energy system. The "Hospital" and "Large Office" (ASHRAE 90.1 2010) prototype building models are examples of models with hydronic HVAC systems, withe the loops named in this way. Future development of the measures will make the loop naming conventions more flexible. 
   
-If the building model does not have a hydronic HVAC system, or neither of the loops are named as described above: 
   The Add Output Variables and Export Time Series to Modelica measures will generate errors, explaning that plant loops with the appropriate names could not be found in the model. No CSV file will be output from the Export Time Series to Modelica measure The "Medium Office" (ASHRAE 90.1 2010) prototype building model is an example of a model without a hydronic HVAC system. 

-If the building model has one, but not both (heating and cooling) of the plant loops named as described above:
   The Add Output Variables measure and Export Time Series to Modelica measure will both generate warnings identifying the plant loop that could not be found. The plant loop for which data is available will have its mass flow rates and temperatures exported to a CSV file. This can be tested by using the "Create DOE Prototype" building model to generate a Large Office or Hospital model (ASHRAE 90.1 2010), and then re-naming one of the loops so that it does not contain the desired string, and using that as the seed model. Such a model is available in this repo, named "example_model_misnamed_loops.osm."
