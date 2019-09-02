(
SynthDef(\bpfbuf, {
	arg atk=0, sus=0, rel=3, c1=1, c2=(-1),
	buf=0, rate=1, spos=0, freq=440, rq=1, bpfmix=0,
	pan=0, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);

	sig = PlayBuf.ar(2, buf, rate*BufRateScale.ir(buf), startPos: spos);
	sig = XFade2.ar(sig, BPF.ar(sig, freq, rq,1/rq.sqrt), bpfmix*2-1);
	sig = sig * env;
	sig = Pan2.ar(sig, pan, amp);

	Out.ar(out, sig);
}).add;
)

Buffer.freeAll;

/**
* USE CASE
*/
(
rrand(4, 10).do{
	Synth(
		\bpfbuf,
		[
			\buf, b[\pads][[0, 1, 2].choose],
			\atk: exprand(2, 3),
			\sus: 1,
			\rel: exprand(2, 3),
			\bpfmix, 1,
			\freq: (Scale.lydian.degrees+69).choose.midicps * [1, 2].choose,
			\rq, exprand(0.001, 0.008),
			\rate: exprand(0.6, 1.2),
			\pan: rrand(-0.5, 0.5),
			\amp: exprand(4, 6),
		]
	);
};
)

(
5.do{
	Synth(
		\bpfbuf,
		[
			\buf, b[\pads][0],
			\atk, 2,
			\rel, 2,
			\spos, rrand(30000, 35000),
			\rate, 0.5 * exprand(0.98, 1.04),
		]
	);
}
)

/**
*  UTILS
*/
(
b = Dictionary.new;
PathName("/Users/Andrix/Projects/supercollider-synths-lib/buffers/").entries.do{
	arg subfolder;
	b.add(
		subfolder.folderName.asSymbol ->
		Array.fill(
			subfolder.entries.size,
			{
				arg i;
				Buffer.read(s, subfolder.entries[i].fullPath);
			}
		)
	);
};
)

b.keys;
b[\pads][[0, 1, 2].choose];
