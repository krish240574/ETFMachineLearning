
/ Technical skill is mastery of complexity, while creativity is mastery of simplicity 

/ Happiness cannot be traveled to, owned, earned, worn or consumed.  
/ Happiness is the spiritual experience of living every minute with love, grace, and gratitude.

onehot:{[dummycol;dummytbl]
	k:group dummytbl dummycol;
	h:value k;
	z:flip ((count ds),(count k))#0;
	:flip (key k)! @'[z;h;:;1]};

pd:{[tf]
	ds::ds[1+til(-1+count ds)];
	ds::ds,'([]mondummy:(count ds)?`Jan`Feb`Mar`Apr`May`Jun`Jul`Aug`Sep`Oct`Nov`Dec),'([]dowdummy:(count ds)?`Mon`Tue`Wed`Thu`Fri`Sat`Sun);
	ta::ds[`AdjClose];
	n::1 2 3 5 10 20 40 60 120 250; / horizons
	l::til count ta;
	np::n!(1,1_prev n); / maintain previous horizons too


/   returns are calculated employing adjusted closing prices, adjusted for stock-splits and dividends, 
/   for the given time periods as measured in trading days: 
/   1, 2, 3, 5, 10, 20, 40, 60, 120 and 250 days using following formula:  
/   r(t-n,t) = P(t)/P(t-n) - 1
	r:(`$"r",/:string n)!{0^{(ta[x]%ta[x-y])-1}[l;x]}each n; 

/ 	Information Set A - Previous n days return and j lagged n days return, where j is equivalent to
/ 	previous horizon (i.e. for 20 days horizon, number of lagged returns will be 10) for all ETFs.
/ 	XA = {rt−n,t,rt−n−1,t−1/, ..., rt−n−j,t−j}
	xa:(`$"xa",/:string n)!{{[t;nn;j;ph]:0f^ta[t-j]%ta[t-nn-j]}[l;x;np x;np x]}each n; 
	
/ 	Information Set B - Average volume for n days and j lagged average volume for n days, where j is
/ 	equivalent to previous horizon for all ETFs.
/ 	XB = {vt−n+1,t, vt−n,t−1 , ..., vt−n−j+1,t−j}
	v::ds[`Volume];
	csum::0;
	xb:(`$"xb",/:string n)!{avg each csum1:{[t;n;ph]c:0;while[c<n;csum+:0^v[t-n-ph+c];c+:1];:csum}[l;x;np x]}each n; / feature set xb - average returns for each horizon, lagged by previous horizon 
	
	raw::(flip r),'(flip xa),'(flip xb); / raw unnormalized data, for the deep neural network - refer paper

	/ demean and descale all features (for SVM and DNN)
	k::flip value r,'xa,'xb;
	k::k-\:avg k;
	fn:{k[;x]%sdev k[;x]}each til count k[0];
	ftbl::flip ((key r), (key xa), (key xb) )! fn[];

	/ if training, demean and descale all features (for SVM and RF)
	/ $["train" like tf;[k::flip value r,'xa,'xb;
	/ 					k::k-\:avg k;
	/ 					fn:{k[;x]%sdev k[;x]}each til count k[0];
	/ 					ftbl::flip ((key r), (key xa), (key xb) )! fn[];]; / try avoiding this global for ftbl
	/ / else tf = test
	/ 					[ftbl::r,'xa,'xb]];


	/ Just get all tables individually (r1, xa1, xb1, y1, r2, xa2, xb2, y2...)
	indi:n!{tbl:flip tmp! ftbl[tmp:(raze over `$("r",(enlist "xa"),(enlist "xb")),/:\:string enlist x)];
			tbl:tbl,'([]y:tbl[`$raze("r",string enlist x)]>=0),'onehot[`mondummy;([]mondummy:(count ds)?`Jan`Feb`Mar`Apr`May`Jun`Jul`Aug`Sep`Oct`Nov`Dec)],
			'onehot[`dowdummy;([]dowdummy:(count ds)?`Mon`Tue`Wed`Thu`Fri`Sat`Sun)]}each n;
	:indi;
	};

c:`Date`Open`High`Low`Close`Volume`AdjClose;
colStr:"DFFFFIF";
.Q.fs[{`spy insert flip c!(colStr;",")0:x}]`:SPY.csv;
/ train dataset
tf:"train";
ds:spy;
train:pd[tf];
/ Delete original non-one-hot categorical columns

.Q.fs[{`spytest insert flip c!(colStr;",")0:x}]`:SPYtest.csv;
ds:spytest;
/ test dataset	
tf:"test";
test:pd[tf];

indiraw:n!{tbl:flip tmp! raw[tmp:(raze over `$("r",(enlist "xa"),(enlist "xb")),/:\:string enlist x)];tbl:tbl,'([]y:tbl[`$raze("r",string enlist x)]>=0), 
			'onehot[`mondummy;([]mondummy:(count ds)?`Jan`Feb`Mar`Apr`May`Jun`Jul`Aug`Sep`Oct`Nov`Dec)],
			'onehot[`dowdummy;([]dowdummy:(count ds)?`Mon`Tue`Wed`Thu`Fri`Sat`Sun)]}each n

