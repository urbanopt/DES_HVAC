

###### (Automatically generated documentation)

# ExportTimeSeriesLoadsCSV

## Description
This measure will add the required output variables and create a CSV file with plant loop level mass flow rates and temperatures for use in a Modelica simulation. Note that this measure has certain
	 requirements for naming of hydronic loops (discussed in the modeler description section).

## Modeler Description
This measure is currently configured to report the temperatures and mass flow rates at the demand outlet and inlet nodes of hot water and chilled water loops, after adding the required output variables to the model. These values can be used to calculate the sum of the demand-side loads, and could thus represent the load on a connection to a district thermal energy system, or on
	building-level primary equipment. This measure assumes that the model includes hydronic HVAC loops, and that the hot water and chilled water loop names can each be uniquely identified by a user-provided string. This measure also assumes that there is a single heating hot water loop
	and a single chilled-water loop per building.

## Measure Type
ReportingMeasure

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

### Number of Decimal Places to Round Mass Flow Rate
Number of decimal places to which mass flow rate will be rounded
**Name:** dec_places_mass_flow,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false

### Number of Decimal Places to Round Temperature
Number of decimal places to which temperature will be rounded
**Name:** dec_places_temp,
**Type:** Integer,
**Units:** ,
**Required:** true,
**Model Dependent:** false




