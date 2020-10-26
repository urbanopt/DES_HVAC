DES_HVAC

Repository for scripts related to modeling of different HVAC systems for buildings in a district served by a district thermal energy system.
Test Suite

The test suite is a project for the Parametric Analysis Tool, in which one can apply the measures in this repo to a model (such as one created by the Create DOE Prototype Building measure) to test them.

Expected behavior from tests:

-If the building model contains a hydronic HVAC system (with the heating loop having "Hot" in its name and the cooling loop having "Chilled" in its name)": Applying the Add Output Variables for Hydronic HVAC measure, and then Export Time Series Loads CSV (in that sequence) should work successfully to generate a time series file of loads (temperatures and mass flow rates for the building-level hydronic HVAC system) for Modelica model of a district thermal energy system. The "Hospital" and "Large Office" (ASHRAE 90.1 2010) prototype building models are examples of models with hydronic HVAC systems, withe the loops named in this way. Future development of the measures will make the loop naming conventions more flexible.

-If the building model does not have a hydronic HVAC system, or neither of the loops are named as described above: The Add Output Variables for Hydronic HVAC measure will generate an error, explaining that appropriately-named plant loops could not be found in the model. As a result, the Export Time Series Loads CSV measure, which follows the Add Output Variables for Hydronic HVAC measure in the workflow, will not run. The "Medium Office" (ASHRAE 90.1 2010) prototype building model is an example of a model without a hydronic HVAC system.

-If the building model has one, but not both (heating and cooling) of the plant loops named as described above: The Add Output Variables for Hydronic HVAC measure and Export Time Series Loads CSV measure will both generate warnings identifying the plant loop that could not be found. The plant loop for which data is available will have its mass flow rates and temperatures exported to a CSV file. This can be tested by using the "Create DOE Prototype" building model to generate a Large Office or Hospital model (ASHRAE 90.1 2010), and then re-naming one of the loops so that it does not contain the desired string, and using that as the seed model. Such a model is available in this repo, named "example_model_misnamed_loops.osm." Note that in order to run this test case, one must also run an alternative with another measure in the workflow having a variable defined. This can be the Create DOE Prototype Building measure, for example, with a variable defined based on it, and the measure skipped in the alternative used to test the behavior for mis-named loops.

Note that the Add Output Varibles for Hydronic HVAC and Export Time Series Loads CSV measures are also predicated on there being exactly one loop with the string 'hot' or 'chilled' in its name. The measures are not yet compatible with multiple hydronic loops of a given type, but could be extended for that purpose in the future.
