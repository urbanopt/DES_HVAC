

###### (Automatically generated documentation)

# ExportTimeSeriesLoadsCSV

## Description
This measure will create a CSV file with plant loop level mass flow rates and temperatures for use in a Modelica simulation. Note that this measure has certain
	 requirements for naming of hydronic loops (discussed in the modeler description section) and requires that certain output variables be present in the model. These
	 output variables can be added with the Add Output Variables for Hydronic HVAC Systems measure.

## Modeler Description
This measure is currently configured to output the temperatures and mass flow rates at the demand outlet and inlet nodes of hot water and chilled water loops. These loads represent the sum of the demand-side loads, and could thus represent the load on a connection to a district thermal energy system, or on
	building-level primary equipment. This measure assumes that the model includes hydronic HVAC loops, and that the hot water loop name contains the word "hot" and the chilled water loop name contains the word "chilled" (non-case-sensitive). This measure also assumes that there is a single heating hot water loop
	and a single chilled-water loop per building. This measure requires that output variables for mass flow rate and temperature at the demand outlet and inlet nodes for the hot water and chilled water
	loops be present in the model. These output variables can be added through the use of the Add Output Variables for Hydronic HVAC Systems measure. This measure will be adapted in the future to be more generic. Note that this measurele
    leverages the "get upstream argument values" approach used in other OpenStudio measures, specifically from "Get Site from Building Component Library."

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

### Use Upstream Argument Values
When true this will look for arguments or registerValues in upstream measures that match arguments from this measure, and will use the value from the upstream measure in place of what is entered for this measure.
**Name:** use_upstream_args,
**Type:** Boolean,
**Units:** ,
**Required:** true,
**Model Dependent:** false




