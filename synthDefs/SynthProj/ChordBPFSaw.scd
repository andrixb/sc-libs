/**
* ChordBPFSw (Stereo)
*/
(
SynthDef(\bpfsaw, {
	arg atk=2, sus=0, rel=3, c1=1, c2=(-1),
	freq=500, detune=1, pan=0,
	cf=1500, cfmin=500, cfmax=2000, rq=0.2,rqmin=0.1, rqmax=0.2, amp=1, out=0;
	var sig, env;

	env = EnvGen.kr(Env([0, 1, 1, 0], [atk, sus, rel], [c1, 0, c2]), doneAction: 2);

	sig = Saw.ar(freq * {LFNoise1.kr(0.5).bipolar(detune).midiratio}!2);
	sig = BPF.ar(
		sig,
		{LFNoise1.kr(0.2).exprange(cfmin, cfmax)}!2,
		{LFNoise1.kr(0.1).exprange(rqmin, rqmax)}!2
	);
	sig = Balance2.ar(sig[0], sig[1], pan);
	sig = sig * env * amp;

	Out.ar(out, sig);
}).add;
)
// =======================================================================
// =======================================================================
(
10.do{
	Synth(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.4,
			\cfmin, 50*2,
			\cfmax, 50*50,
			\rqmin, 0.005,
			\rqmax, 0.03,
			\pan, 0,
		]
	);
};
)

// =======================================================================
// Chord Unisone
(
4.do{
	Synth(
		\bpfsaw,
		[
			\freq, exprand(100, 1000),
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5),
		]
	);
};
)

// Chord Polyphone
(
[58, 65, 68, 73].midicps.do{
	arg f;

	Synth(
		\bpfsaw,
		[
			\freq, f,
			\amp, 0.25,
			\cf, f * exprand(1, 12),
			\rq, exprand(0.01, 0.5),
		]
	);
}
)

// Chord Polyphone Random Notes (from minor scale)
(
4.do{
	Synth(
		\bpfsaw,
		[
			\freq, (Scale.minor.degrees+60).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5),
		]
	);
};
)

// Chord Polyphone With Random Notes (from minor scale) And OSCs Number
(
(1..6).choose.do{
	Synth(
		\bpfsaw,
		[
			\freq, (Scale.minor.degrees+60).midicps.choose,
			\amp, 0.25,
			\cf, exprand(200, 5000),
			\rq, exprand(0.01, 0.5),
		]
	);
};
)

// Bass Pad
(
10.do{
	Synth(
		\bpfsaw,
		[
			\freq, 50,
			\amp, 0.2,
		]
	);
};
)
