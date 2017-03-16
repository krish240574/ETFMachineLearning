c:`Date`Open`High`Low`Close`Volume`AdjClose;
colStr:"DFFFFIF";
.Q.fs[{`spy insert flip c!(colStr;",")0:x}]`:SPY.csv;
spy:spy[1+til(-1+count spy)];
ta:spy[`AdjClose];
n:1 2 3 5 10 20 40 60 120 250; / horizons
l:til count ta;
np:n!(1,1_prev n); / maintain previous horizons too

r:(`$"r",/:string n)!{0^{(ta[x]%ta[x-y])-1}[l;x]}each n; / returns for various horizons

f:{[t;nn;j;ph]:0f^ta[t-j]%ta[t-nn-j]}; 
xa:(`$"xa",/:string n)!{f[l;x;np x;np x]}each n; / feature set xa - {rt−n,t,rt−n−1,t−1, ..., rt−n−j,t−j} 

v:spy[`Volume];
f:{[t;n;ph]c:0;while[c<n;csum+:0^v[t-n-ph+c];c+:1];:csum}
xb:(`$"xb",/:string n)!{csum:f[l;x;np x];avg each csum}each n;

ftbl:((flip r), '(flip xa)),'flip xb;
/ Just get all tables individually (r1, xa1, xb1, y1, r2, xa2, xb2, y2...)
indi:n!{tbl:flip tmp! ftbl[tmp:(raze over `$("r",(enlist "xa"),(enlist "xb")),/:\:string enlist x)];tbl:tbl,'([]y:tbl[`$raze("r",string enlist x)]>=0)}each n

