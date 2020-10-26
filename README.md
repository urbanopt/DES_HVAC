# DES_HVAC
Repository for scripts related to modeling of different HVAC systems for buildings in a district served by a district thermal energy system. 

# Test Suite
The test suite is a project for the Parametric Analysis Tool, in which one can apply the measures in this repo to a model (such as one created by the Create DOE Prototype Building measure) to test them. 

Expected behavior from tests: 

-If the building model contains a hydronic HVAC system (with the heating loop having "Hot" in its name and the cooling loop having "Chilled" in its name)":
   Applying the Add Output Variables measure, and then Export Time Series to Modelica (in that sequence) should work successfully to generate a time series file of loads (temperatures and mass flow rates for the building-level hydronic HVAC system) for Modelica model of a district thermal energy system. The "Hospital" and "Large Office" prototype building models are examples of models with hydronic HVAC systems, withe the loops named in this way. Future development of the measures will make the loop naming conventions more flexible. 
   
-If the building model does not have a hydronic HVAC system, or the loops are not named as described above: 
   The Add Output Variables measure and Export Time Series to Modelica measures will return a warning message explaining that a loop or loops as named above could not be found in the building model. A CSV file will be output with the time stamp columns, but none others, for the load profiles. 
