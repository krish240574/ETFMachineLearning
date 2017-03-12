/ Read dataset
c:`Date`Open`High`Low`Close`Volume`AdjClose;
colStr:"DFFFFIF";
.Q.fs[{`spy insert flip c!(colStr;",")0:x}]`:SPY.csv; / Just reading the SPY data for now, still building up the code. 
/ Get rid of column header
spy:spy[1+til(-1+count spy)];

t:spy[`AdjClose];
n:1 2 3 5 10 20 40 60 120 250; / horizons
r:{0^{(t[x]%t[x-y])-1}[til count t;x]}each n; / returns for various horizons

/ Information set A -  Previous n days return and j lagged n days return, where j is equivalent to
/ previous horizon (i.e. for 20 days horizon, number of lagged returns will be 10) for all ETFs.
l:1+til (-1+count t);
f:{[x;y;z;a]if[z<a;f[x;y;z+1;a]];0^t[x-z]%t[x-y-z]}; 
xa:{f[l;x;0;prev x]}each n; / feature set xa - {rt−n,t,rt−n−1,t−1, ..., rt−n−j,t−j} 

/ Information set B - Information Set B - Average volume for n days and j lagged average volume for n days, where j is
/ equivalent to previous horizon for all ETFs.
csum:0f;
f:{[x;y;z;a]if[z<a;f[x;y;z+1;a]];csum::csum+t[x-y-z+1]};
xb:{f[l;x;0;prev x];0^csum%prev x}each n;
