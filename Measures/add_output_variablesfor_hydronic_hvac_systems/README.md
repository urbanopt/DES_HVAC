

###### (Automatically generated documentation)

# Add Output Variables for Hydronic HVAC Systems

## Description
This measure adds output variables for temperature and mass flow rate at the demand inlet node for hydronic HVAC loops. This measure can be used to generate a time series for modeling a building load attached to a district thermal energy system. The output variables are added at the simulation timestep. 

## Modeler Description
This measure requires that heating hot water and chilled water loops (one of each) be present in the model, and that the heating hot water loop have the word "hot" in its name, and that the chilled water loop have the word "chilled" in its name (non case sensitive). 
	This measure will be modified in the future to be more generic.

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Name or Partial Name of Heating Hot Water Loop, non-case-sensitive

**Name:** hhw_loop_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Name or Partial Name of Chilled Water Loop, non-case-sensitive

**Name:** chw_loop_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false




