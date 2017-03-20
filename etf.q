


pd:{[tf]
	ds::ds[1+til(-1+count ds)];
	ta::ds[`AdjClose];
	n:1 2 3 5 10 20 40 60 120 250; / horizons
	l::til count ta;
	np::n!(1,1_prev n); / maintain previous horizons too

	r:(`$"r",/:string n)!{0^{(ta[x]%ta[x-y])-1}[l;x]}each n; / returns for various horizons

	/ f:{[t;nn;j;ph]:0f^ta[t-j]%ta[t-nn-j]}; 
	xa:(`$"xa",/:string n)!{{[t;nn;j;ph]:0f^ta[t-j]%ta[t-nn-j]}[l;x;np x;np x]}each n; / feature set xa - {rt−n,t,rt−n−1,t−1, ..., rt−n−j,t−j} 

	v::ds[`Volume];
	/ f:{[t;n;ph]c:0;while[c<n;csum+:0^v[t-n-ph+c];c+:1];:csum}
	csum::0;
	xb:(`$"xb",/:string n)!{avg each csum1:{[t;n;ph]c:0;while[c<n;csum+:0^v[t-n-ph+c];c+:1];:csum}[l;x;np x]}each n; / feature set xb - average returns for each horizon, lagged by previous horizon 

	/ if training, demean and descale all features (for SVM and RF)
	$["train" like tf;[k::flip value r,'xa,'xb;
						k::k-\:avg k;
						fn:{k[;x]%sdev k[;x]}each til count k[0];
						ftbl::flip ((key r), (key xa), (key xb) )! fn[];];
	/ else tf = test
						[ftbl::r,'xa,'xb]];


	/ Just get all tables individually (r1, xa1, xb1, y1, r2, xa2, xb2, y2...)
	indi:n!{tbl:flip tmp! ftbl[tmp:(raze over `$("r",(enlist "xa"),(enlist "xb")),/:\:string enlist x)];tbl:tbl,'([]y:tbl[`$raze("r",string enlist x)]>=0)}each n;
	:indi;
	};

c:`Date`Open`High`Low`Close`Volume`AdjClose;
colStr:"DFFFFIF";
.Q.fs[{`spy insert flip c!(colStr;",")0:x}]`:SPY.csv;
tf:"train";
ds:spy;
train:pd[tf];
.Q.fs[{`spytest insert flip c!(colStr;",")0:x}]`:SPYtest.csv;
ds:spytest;
tf:"test";
test:pd[tf]

