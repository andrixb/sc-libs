(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, detune=1, pan=0, cfhzmin=0.1, cfhzmax=0.3,
	cf=1500, cfmin=500, cfmax=2000, rq=0.2,rqmin=0.1, rqmax=0.2,
	lsf=200, ldb=0, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);

	sig = Saw.ar(freq * {LFNoise1.kr(0.5).bipolar(detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(
			LFNoise1.kr(4).exprange(cfhzmin, cfhzmax)
		).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);

	sig = BLowShelf.ar(sig, lsf, 0.5, ldb);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;
)

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

~b1 = Buffer.read(s, "/Users/Andrix/Projects/supercollider-synths-lib/proj_sounds/drum_kit_TR808/Clava/Clava_Accent.wav");
~b2 = Buffer.read(s, "/Users/Andrix/Projects/supercollider-synths-lib/proj_sounds/drum_kit_TR808/Congas/Congas_Hi_Accent_Max_Decay.wav");
~b3 = Buffer.read(s, "/Users/Andrix/Projects/supercollider-synths-lib/proj_sounds/drum_kit_TR808/Cymbal/Cymbal_Accent_Max_Decay.wav");

~b1.numChannels;

(
Synth(
	\bpfbuf,
	[
		\buf, [~b1, ~b2, ~b3].choose,
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
)




