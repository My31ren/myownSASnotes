/*Define work path*/
%global path;
%let path=/folders/myfolders/GTL/;

/*Use stored macros*/
LIBNAME DEMO "/folders/myfolders/demo";
OPTIONS MSTORED SASMSTORE=DEMO NOSOURCE;

/*define output filename*/
filename odsout "/folders/myfolders/odsout";

/*1-Create a simulation data to perform Survival analyses*/
data Study;
input Group : $10. Time Status @@;
label Time="Time (Days)";
datalines;
Low-Risk  2569 0 Low-Risk  2506 0 Low-Risk  2409 0
Low-Risk  2218 0 Low-Risk  1857 0 Low-Risk  1829 0
Low-Risk  1562 0 Low-Risk  1470 0 Low-Risk  1363 0
Low-Risk  1030 0 Low-Risk   860 0 Low-Risk  1258 0
Low-Risk  2246 0 Low-Risk  1870 0 Low-Risk  1799 0
Low-Risk  1709 0 Low-Risk  1674 0 Low-Risk  1568 0
Low-Risk  1527 0 Low-Risk  1324 0 Low-Risk   957 0
Low-Risk   932 0 Low-Risk   847 0 Low-Risk   848 0
Low-Risk  1850 0 Low-Risk  1843 0 Low-Risk  1535 0
Low-Risk  1447 0 Low-Risk  1384 0 Low-Risk   414 1
Low-Risk  2204 1 Low-Risk  1063 1 Low-Risk   481 1
Low-Risk   105 1 Low-Risk   641 1 Low-Risk   390 1
Low-Risk   288 1 Low-Risk   421 1 Low-Risk    79 1
Low-Risk   748 1 Low-Risk   486 1 Low-Risk    48 1
Low-Risk   272 1 Low-Risk  1074 1 Low-Risk   381 1
Low-Risk    10 1 Low-Risk    53 1 Low-Risk    80 1
Low-Risk    35 1 Low-Risk   248 1 Low-Risk   704 1
Low-Risk   211 1 Low-Risk   219 1 Low-Risk   606 1
High-Risk 2640 0 High-Risk 2430 0 High-Risk 2252 0
High-Risk 2140 0 High-Risk 2133 0 High-Risk 1238 0
High-Risk 1631 0 High-Risk 2024 0 High-Risk 1345 0
High-Risk 1136 0 High-Risk  845 0 High-Risk  422 1
High-Risk  162 1 High-Risk   84 1 High-Risk  100 1
High-Risk    2 1 High-Risk   47 1 High-Risk  242 1
High-Risk  456 1 High-Risk  268 1 High-Risk  318 1
High-Risk   32 1 High-Risk  467 1 High-Risk   47 1
High-Risk  390 1 High-Risk  183 1 High-Risk  105 1
High-Risk  115 1 High-Risk  164 1 High-Risk   93 1
High-Risk  120 1 High-Risk   80 1 High-Risk  677 1
High-Risk   64 1 High-Risk  168 1 High-Risk   74 1
High-Risk   16 1 High-Risk  157 1 High-Risk  625 1
High-Risk   48 1 High-Risk  273 1 High-Risk   63 1
High-Risk   76 1 High-Risk  113 1 High-Risk  363 1
;
run;
ods exclude where=(_name_^='SurvivalPlot');
ods graphics / reset width=800px height=520px;
ods html style=journal path=odsout file="7-stepplot.html";
ods output survivalplot=plotdata;
proc lifetest data=Study plots=survival(cl);
   time Time * Status(0);
   survival;
   strata Group;
run;
ods exclude none;

/*2-Use GTL stepplot to customize Survival plot*/

*A glance at dataset being used;
%head(plotdata, obs=10);

/*2.1generate template*/
ods _all_ close;
ods html style=journal path=odsout file="7-stepplot.html";
proc template;
	define statgraph mysurvival;
		begingraph / datacontrastcolors=(cxec6f77 cx24ff61) datacolors=(cxec6f77 cx24ff61);
		entrytitle textattrs=(size=12 family="Times New Roman" weight=bold) 
			"K-M Survival plot";
		entryfootnote halign=left textattrs=(size=9 family="Times New Roman" 
			weight=normal color=CX8470FF) "Note: made by Myren";
		layout overlay / 
			yaxisopts=(label="Proportion of Survival" labelattrs=(size=12 family="Times New Roman" weight=bold))
			xaxisopts=(label="Time(Days)" labelattrs=(size=12 family="Times New Roman" weight=bold));
			bandplot x=time limitlower=sdf_lcl limitupper=sdf_ucl / group=stratum datatransparency=0.95;
			stepplot x=time y=survival /
				group=stratum name="step" lineattrs=(thickness=2 pattern=solid);
			scatterplot x=time y=censored / name="scatter" legendlabel="Censored"
				markerattrs=(size=14 symbol=plus color=cxa86a61);
			discretelegend "step" / autoitemsize=true valueattrs=(size=12)
				location=inside valign=top halign=center;
			discretelegend "scatter" / autoitemsize=true valueattrs=(size=12)
				location=inside valign=top halign=right;
		endlayout;
		endgraph;
	end;
run;
proc sgrender data= plotdata template=mysurvival;
run;
ods graphics on;

/*2.2 Macro execution to draw KM plot*/
ods graphics / reset width=700px height=520px;
ods html style=journal path=odsout file="7-stepplot.html";
%km_plot(study,time,status,group,colors=yellow blue);


/*2.3 customized symbols*/
ods _all_ close;
ods html style=htmlblue path=odsout file="7-stepplot.html";
proc template;
	define statgraph mysurvival;
		begingraph / datacontrastcolors=(cxec6f77 cx24ff61) datacolors=(cxec6f77 cx24ff61);
			
			/*Define customized symbols*/
			symbolchar name=high char='2640'x;
			symbolchar name=low char='2642'x;
			
			/*Define legend entries for the customized symbols*/
			legenditem type=marker name="high" / 
            	markerattrs=(symbol=high size=25 color=cxec6f77) 
            	label="High-risk Censor";
			legenditem type=marker name="low" / 
            	markerattrs=(symbol=low size=25 color=cx24ff61) 
            	label="Low-risk Censor";            	
			
			/*Define an attribute map*/
			discreteattrmap name="stratummap";
				value "High-Risk" / markerattrs=(symbol=high);
				value "Low-Risk" / markerattrs=(symbol=low);
			enddiscreteattrmap;
			discreteattrvar attrvar=mkgroup var=stratum attrmap="stratummap";
		
		entrytitle textattrs=(size=12 family="Times New Roman" weight=bold) 
			"K-M Survival plot";
		entryfootnote halign=left textattrs=(size=9 family="Times New Roman" 
			weight=normal color=CX8470FF) "Note: made by Myren";
		layout overlay / 
			yaxisopts=(label="Proportion of Survival" labelattrs=(size=12 family="Times New Roman" weight=bold))
			xaxisopts=(label="Time(Days)" labelattrs=(size=12 family="Times New Roman" weight=bold));
			bandplot x=time limitlower=sdf_lcl limitupper=sdf_ucl / group=stratum datatransparency=0.95;
			stepplot x=time y=survival /
				group=stratum name="step" lineattrs=(thickness=2 pattern=solid);
			scatterplot x=time y=censored / name="scatter" legendlabel="Censored"
				group=mkgroup markerattrs=(size=30 );
			discretelegend "step" / autoitemsize=true valueattrs=(size=12)
				location=inside valign=top halign=center;
			discretelegend "high" "low" / order=columnmajor valueattrs=(size=12)
				location=inside valign=top halign=right;
		endlayout;
		endgraph;
	end;
run;
proc sgrender data= plotdata template=mysurvival;
run;
ods graphics on;

