/*--step1:create a simulation dataframe--*/
%global elements;
%let elements=Pb Hg As Cd;*prepare a list of var-name that you draw the figure; 
%macro create;
%local i j sgvar;
	%do j=1 %to 500;
		%do i=1 %to %sysfunc(countw(&elements.));
			%let sgvar=%scan(&elements.,&i.);
			length &sgvar. 6.3;
			&sgvar.=rannor(seed) + &i.;
		%end;*end i;
		group="A";
		%if &j. > 250 %then %do;
			group="B";
		%end;*end if;
		output;
	%end;*end j;
%mend create;
data have;*named have;
	seed=2020;
	retain seed;
	%create;
	drop seed;
run;
/*1. primary plot*/
proc template;
	define statgraph test;
		begingraph;
		layout overlay;
			scatterplot x=pb y=hg;
			histogram cd / primary=true;
		endlayout;
		endgraph;
	end;
run;
proc sgrender data=have template=test;
	title "scatterplot is primary plot";
run;
/*2. statement order*/
proc template;
	define statgraph test2;
	begingraph;
		entrytitle "Modelband statement at first";
		layout overlay;
			modelband "cli";
			scatterplot x=hg y=pb;
			regressionplot x=hg y=pb /cli="cli";
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;
/*3. x2  y2*/
proc template;
	define statgraph test2;
	begingraph;
		entrytitle "scatter--y2--pb's concentration";
		entrytitle "histogram--y--hg's frequency";
		layout overlay / walldisplay=(fill);
			histogram hg/yaxis=y;
			scatterplot x=hg y=pb/ yaxis=y2;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;
/*4. turn off the walldisplay*/
proc template;
	define statgraph test2;
	begingraph;
		entrytitle "Xaxis --label and tickvalues are displayed";
		layout overlay /xaxisopts=(display=(label tickvalues));
			histogram hg/yaxis=y;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;

/*4. axis label*/
ods graphics / reset width=400px height=300px;
proc template;
	define statgraph test2;
	begingraph;
		entrytitle "x-Labelposition=left, y-Labelposition=top";
		layout overlay /xaxisopts=(label="Hg concentration (μg/g)" labelposition=left
			labelattrs=(size=12 color=red family="Times New Roman" weight=bold))
				yaxisopts=(labelposition=top);
			histogram hg/yaxis=y;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;

/*5. threshold*/
proc univariate data=have;
	var hg;
run;
ods graphics / reset width=400px height=300px;
proc template;
	define statgraph test2;
	begingraph;
		entrytitle "Thresholdmax=0 and Thresholdmin=0";
		layout overlay /xaxisopts=(label="Hg concentration (μg/g)"
			labelattrs=(size=12 color=red family="Times New Roman" weight=bold))
			yaxisopts=(linearopts=(thresholdmax=0 thresholdmin=0)griddisplay=on)
			y2axisopts=(linearopts=(thresholdmax=0 thresholdmin=0));
			histogram hg/yaxis=y;
			histogram hg/yaxis=y2 scale=count;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;
/*Linear axis*/
/*6. tickvaluelist tickdisplaylist*/
proc template;/**/
	define statgraph test2;
	begingraph;
		*you can also use tickvaluesequence=(start end increment) to specify;
		entrytitle "specify yaxis Tickvalueformat as 5.2.";
		layout overlay /
			xaxisopts=(linearopts=(tickvaluelist=(0 1 2 3 4 5) tickdisplaylist=());
			histogram hg;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;

/*7. tickvaluefitpolicy*/
proc template;/**/
	define statgraph test2;
	begingraph;
		*you can also use tickvaluesequence=(start end increment) to specify;
		entrytitle "Tickvaluefitpolicy=rotate tickvaluerotation=diagonal2" ;
		layout overlay /
			xaxisopts=(linearopts=(tickvalueformat=dollar6.2 tickvaluefitpolicy=rotate tickvaluerotation=diagonal2));
			histogram hg;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;

/*8. includeranges*/
ods graphics / reset width=400 height=250;
proc template;/**/
	define statgraph test2;
	begingraph / axisbreaktype=axis;
		*you can also use tickvaluesequence=(start end increment) to specify;
		entrytitle "Axisbreaktype=axis in begingraph statement" ;
		layout overlay /
			xaxisopts=(linearopts=(includeranges=(0-2 4-5)));
			scatterplot x=hg y=pb;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;

/*Discrete axis*/
/*8. tickvalueformat*/
ods graphics / reset width=400 height=250;
proc format;
	value $tickvlfmt
		"A"="Case group"
		"B"="Control group"
		"C"="Missing";
run;
proc template;/**/
	define statgraph test2;
	begingraph / axisbreaktype=axis;
		entrytitle "Tickvalueformat + proc format" ;
		layout overlay /
			xaxisopts=(discreteopts=(tickvalueformat=$tickvlfmt. tickvaluelist=("B" "A" "C")));
			boxplot x=group y=hg;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;
/*9. Colorband*/
ods graphics / reset width=400 height=250;
proc template;/**/
	define statgraph test2;
	begingraph / axisbreaktype=axis;
		entrytitle "Color band and its attributes" ;
		layout overlay /
			xaxisopts=(discreteopts=(tickvaluelist=("B" "A" "C" "D" "E") colorbands=even colorbandsattrs=(transparency=0.7 color=grey)));
			boxplot x=group y=hg;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=have template=test2;
run;
/*Time axis*/
/*10. interval splittickvalue*/
proc template;
	define statgraph dfttimeaxis;
	begingraph;
	entrytitle "Tickvaluelist viewmin viewmax";
		layout overlay /
			xaxisopts=(timeopts=(interval=month
				splittickvalue=false tickvaluefitpolicy=rotate));
			seriesplot x=date y=close;
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=sashelp.stocks template=dfttimeaxis;
	where stock="IBM" and date between "1jan2004"d and "31dec2005"d;
run;
/*includeranges*/
proc template;
	define statgraph stockplot;
	begingraph;
	entrytitle "Data from 1990 to 1995 is not shown.";
		layout overlay /
			xaxisopts=(timeopts=(
				includeranges=('01jan1986'd-'31dec1989'd '01jan1996'd-'31dec2005'd) 
				tickvalueformat=year4.));
			seriesplot x=date y=close / name="series" group=stock;
			discretelegend "series";
		endlayout;
	endgraph;
	end;
run;
proc sgrender data=sashelp.stocks template=stockplot;
run;
