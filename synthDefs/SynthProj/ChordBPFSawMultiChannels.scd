(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, detune=1, pan=0,
	cf=1500, cfmin=500, cfmax=2000, rq=0.2,rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);

	sig = Saw.ar(freq * LFNoise1.kr(0.5).bipolar(detune).midiratio);
	sig = BPF.ar(
		sig,
		LFNoise1.kr(0.2).exprange(cfmin, cfmax),
		LFNoise1.kr(0.1).exprange(rqmin, rqmax)
	);

	// sig = PanAz.ar(8, sig, LFSaw.kr(0.5));
	// sig = PanAz.ar(8, sig, LFNoise1.kr(1));
	sig = PanAz.ar(8, sig, pan);

	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;
)

/**
* Utils
*/
s.options.numOutputBusChannels_(8);
s.reboot;
s.meter;

/**
* Use Case
*/
(
10.do{
	Synth(
		\bpfsaw,
		[
			\freq, 20,
			\amp, 0.5,
			\detune, 1,
			\cfmin, 20*40,
			\cfmax, 20*50,
			\pan, 0.5,
		]
	);
};
)

(
10.do{
	Synth(
		\bpfsaw,
		[
			\freq, 20,
			\amp, 0.5,
			\detune, 1,
			\cfmin, 20*40,
			\cfmax, 20*50,
		]
	);
};
)
