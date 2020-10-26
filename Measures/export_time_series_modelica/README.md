

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
	loops be present in the model. These output variables can be added through the use of the Add Output Variables for Hydronic HVAC Systems measure. This measure will be adapted in the future to be more generic. 

## Measure Type
ReportingMeasure

## Taxonomy


## Arguments




This measure does not have any user arguments


