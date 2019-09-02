// https://github.com/theseanco/howto_co34pt_liveCode

(
SynthDef(\hrsynth,{
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


SynthDef(\prophet5pwmstrings,{|out= 0 freq = 440 amp = 1.0 gate=1 lforate = 10 lfowidth= 0.5 cutoff= 12000 rq=0.5 pan = 0.0|

	var lfo, pulse, filter, env;

	lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);

	pulse = Pulse.ar(freq*[1,1.01],lfo*lfowidth+0.5);

	filter = RLPF.ar(pulse,cutoff,rq);

	env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.5),gate,doneAction:2);

	Out.ar(out,Pan2.ar(Mix(filter)*env*amp*0.5,pan));

}).add;
)

(
SynthDef(\delayeffect, {|out =0 gate= 1|
	var source = In.ar(out,2);
	var delay;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	delay= CombC.ar(source,0.25,0.25,2.0);

	XOut.ar(out,env, delay);
}).add;

SynthDef(\choruseffect, {|out =0 gate= 1|
	var source = In.ar(out,2);
	var chorus;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	chorus= Mix.fill(7, {
		var maxdelaytime= rrand(0.005,0.02);
		DelayC.ar(source, maxdelaytime,LFNoise1.kr(Rand(4.5,10.5),0.25*maxdelaytime,0.75*maxdelaytime) )
	});

	XOut.ar(out,env, chorus);
}).add;
)

Scale.directory;

// TempoClock.default.tempo = 84/60;

(
~drone =
Pbind(
	\instrument, \hrsynth,
	\scale, #[0, 2, 3, 5, 7, 8, 10],
	\root, 2,
	\degree, Pseq(#[rest, 4, 3, 4, 2, 4, 1, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2, 4,
		-3, 4, -1.9, 4, -0.9, 4, 0, 4, -0.9, 4, 0, 4, 1, 4, 2], 1),
	\dur, 0.25,
	// \freq, Pseq([1, 1, 1, 1], 2),
	\detune, Pwhite(0.03,0.2),
	\rqmin, 0.08,
	\rqmax, 0.12,
	\cfmin, 50,
	\cfmax, 400,
	\atk, 2,
	\sus, 0.1,
	\rel, 2,
	\amp, 0.5
).play
)

(
~marimba = Pbind(
	\instrument, \bpfsaw,
	\dur, Prand([1, 1, 1, 1], 1),
	\freq, Pseq([2, 2, 2, 2], 2),
	\detune, Pwhite(0, 0.1),
	\rqmin, 0.005,
	\rqmax, 0.008,
	\cfmin, Prand((Scale.major.degrees+64).midicps,inf) * Prand([0.5,1,2,4],inf),
	\cfmax, Pkey(\cfmin) * Pwhite(1.008,1.025),
	\atk, 0,
	\sus, 0,
	\rel, 1,
	\amp, 1,
).play;
)

(
12.do{
	Synth(
		\bpfsaw,
		[
			\atk, exprand(0.5,1.5),
			\rel, exprand(2.0,8.0),
			\c1, exprand(4,10.0),
			\c2, exprand(2.0,5).neg,
			\freq, exprand(8,60),
			\detune, rrand(0.1,4),
			\cfmin, 30,
			\cfmax, 400,
			\rqmin, 0.02,
			\rqmax, 0.08,
			\amp, exprand(0.5,0.9),
			\pan, rrand(-0.5,0.5),
		]
	);
};
)


~drone.free;
s.freeAll;


Env.new([0, 1, 0.2, 0], [2, 0, 3], [1, 0, -1]).plot


// Drum Machine
(
SynthDef(\kick, {
	|out = 0, pan = 0, amp = 0.3|
	var body, bodyFreq, bodyAmp;
	var pop, popFreq, popAmp;
	var click, clickAmp;
	var snd;

	// body starts midrange, quickly drops down to low freqs, and trails off
	bodyFreq = EnvGen.ar(Env([261, 120, 51], [0.035, 0.08], curve: \exp));
	bodyAmp = EnvGen.ar(Env.linen(0.005, 0.1, 0.3), doneAction: 2);
	body = SinOsc.ar(bodyFreq) * bodyAmp;
	// pop sweeps over the midrange
	popFreq = XLine.kr(750, 261, 0.02);
	popAmp = EnvGen.ar(Env.linen(0.001, 0.02, 0.001)) * 0.15;
	pop = SinOsc.ar(popFreq) * popAmp;
	// click is spectrally rich, covering the high-freq range
	// you can use Formant, FM, noise, whatever
	clickAmp = EnvGen.ar(Env.perc(0.001, 0.01)) * 0.15;
	click = LPF.ar(Formant.ar(910, 4760, 2110), 3140) * clickAmp;

	snd = body + pop + click;
	snd = snd.tanh;

	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\snare, {
	|out = 0, pan = 0, amp = 0.3|
	var pop, popAmp, popFreq;
	var noise, noiseAmp;
	var snd;

	// pop makes a click coming from very high frequencies
	// slowing down a little and stopping in mid-to-low
	popFreq = EnvGen.ar(Env([3261, 410, 160], [0.005, 0.01], curve: \exp));
	popAmp = EnvGen.ar(Env.perc(0.001, 0.11)) * 0.7;
	pop = SinOsc.ar(popFreq) * popAmp;
	// bandpass-filtered white noise
	noiseAmp = EnvGen.ar(Env.perc(0.001, 0.15), doneAction: 2);
	noise = BPF.ar(WhiteNoise.ar, 810, 1.6) * noiseAmp;

	snd = (pop + noise) * 1.3;

	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;

SynthDef(\hihat, {
	|out = 0, pan = 0, amp = 0.3|
	var click, clickAmp;
	var noise, noiseAmp;
	var snd;

	// noise -> resonance -> expodec envelope
	noiseAmp = EnvGen.ar(Env.perc(0.001, 0.3, curve: -8), doneAction: 2);
	noise = Mix(BPF.ar(ClipNoise.ar, [4010, 4151], [0.15, 0.56], [1.0, 0.6])) * 0.7 * noiseAmp;

	snd = noise;

	Out.ar(out, Pan2.ar(snd, pan, amp));
}).add;


SynthDef(\ohat, {arg
	gate = 1,
	decay = 0.2,
	sustain = 0.5,
	release = 0.1,
	amp = 0.5;

	var env = EnvGen.kr(Env.adsr(0.01, decay, sustain, release), gate, doneAction: 2);
	var noise = WhiteNoise.ar(env);
	var filter = RHPF.ar(noise, 8000, 0.5);

	Out.ar([0,1], filter * amp);
}).add;

// adapted from a post by Neil Cosgrove (other three are original)
SynthDef(\clap, {
	|out = 0, amp = 0.5, pan = 0, dur = 1|
	var env1, env2, snd, noise1, noise2;

	// noise 1 - 4 short repeats
	env1 = EnvGen.ar(
		Env.new(
			[0, 1, 0, 0.9, 0, 0.7, 0, 0.5, 0],
			[0.001, 0.009, 0, 0.008, 0, 0.01, 0, 0.03],
			[0, -3, 0, -3, 0, -3, 0, -4]
		)
	);

	noise1 = WhiteNoise.ar(env1);
	noise1 = HPF.ar(noise1, 600);
	noise1 = LPF.ar(noise1, XLine.kr(7200, 4000, 0.03));
	noise1 = BPF.ar(noise1, 1620, 3);

	// noise 2 - 1 longer single
	env2 = EnvGen.ar(Env.new([0, 1, 0], [0.02, 0.18], [0, -4]), doneAction:2);

	noise2 = WhiteNoise.ar(env2);
	noise2 = HPF.ar(noise2, 1000);
	noise2 = LPF.ar(noise2, 7600);
	noise2 = BPF.ar(noise2, 1230, 0.7, 0.7);

	snd = noise1 + noise2;
	snd = snd * 2;
	snd = snd.softclip;

	Out.ar(out, Pan2.ar(snd,pan,amp));
}).add;
)

(
var drumkit, synth;

drumkit = Pbind(\amp, 0.3);
synth = Pbind(\amp, 0.05);

Ppar([
	/*Pbindf(
		drumkit,
		\instrument, Pseq([\kick, \snare, \kick, \kick, \snare], inf),
		\dur, Pseq([4, 4, 2, 2, 4], inf)
	),*/
	Pbindf(
		drumkit,
		\instrument, Pseq([Pn(\hihat, 4), Pn(\ohat, 2), Pn(\hihat, 2)], inf),
		\dur, Pseq([2, 2, 2, 2, Rest(2), 2, Rest(2), 2], inf)
	),
	Pbindf(
		synth,
		\instrument, Pseq([\prophet5pwmstrings], inf),
		\midinote, Pseq([0,3,8,7,5,8,7,3]+48,inf),
		\dur, Pseq((1.0!8),inf),
		\lfowidth, Pn(Pseries(0.0, 0.025,7),inf),
		\lforate, Pn(Pseries(2, 1, 11),inf),
		\rq, Pn(Pseries(0.9, -0.1, 5),inf)
	)
]).play(TempoClock(2 * 4));
)
