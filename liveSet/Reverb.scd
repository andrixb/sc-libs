
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


(
SynthDef(\reverb, {
	arg in, predelay=0.1, revtime=1.8, lpf=4500, mix=0.15, amp=1, out=0;
	var dry, wet, temp, sig;

	dry = In.ar.(in, 2);
	temp = In.ar(in, 2);
	wet = 0;
	temp = DelayN.ar(temp, 0.2, predelay);

	16.do {
		temp = AllpassN.ar(temp, 0.05, {Rand(0.001, 0.05)}!2, revtime);
		temp = LPF.ar(temp, lpf);
		wet = wet + temp;
	};

	sig = XFade2.ar(dry, wet, mix*2-1, amp);

	Out.ar(out, sig);
}).add;
)

~reverbBus = Bus.audio(s, 2);
~reverbSynth = Synth(\reverb, [\in, ~reverbBus]);

(
p = Pbind(
	\instrument, \bpfbuf,
	\dur, Pexprand(0.1, 1),
	\buf, Pxrand(b[\pads][(0..2)]++b[\ambient][(0..1)], inf),
	\rel, Pexprand(0.01, 0.5),
	\spos, Pwhite(1, 10),
	\rate, Pwhite(-7.0, 7.0).midiratio,
	\amp, Pexprand(0.5, 0.9),
	\out, Prand([~reverbBus, 0], inf);
).play;
)


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