(
//make sure server is booted if you want to hear any sound!
s.boot;

//bpm 120 assumed in the following, impacting on some delay recipes.
TempoClock.default.tempo = 2;
)

(//Effects
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


SynthDef(\delayeffect, {|out =0 gate= 1|
	var source = In.ar(out,2);
	var delay;
	var env = Linen.kr(gate, 0.1, 1, 0.1, 2);

	delay= CombC.ar(source,0.25,0.25,2.0);

	XOut.ar(out,env, delay);
}).add;

SynthDef(\yazoodelayeffect, {|out =0 gate= 1 pan= 0.1|
	var source = In.ar(out,2);
	var delay;
	var env = Linen.kr(gate, 0.0, 1, 0.1, 2);

	delay= DelayC.ar(source[0].distort,0.25,0.25);

	Out.ar(out,Pan2.ar(delay*env,pan));
}).add;
)

(// Synth definitions
SynthDef(\prophet5pwmstrings,{
	|out= 0 freq = 440 amp = 1.0 gate=1 lforate = 10 lfowidth= 0.5 cutoff= 12000 rq=0.5 pan = 0.0|

	var lfo, pulse, filter, env;

	lfo = LFTri.kr(lforate*[1,1.01],Rand(0,2.0)!2);
	pulse = Pulse.ar(freq*[1,1.01],lfo*lfowidth+0.5);
	filter = RLPF.ar(pulse,cutoff,rq);
	env = EnvGen.ar(Env.adsr(0.01,0.0,1.0,0.5),gate,doneAction:2);

	Out.ar(out,Pan2.ar(Mix(filter)*env*amp*0.5,pan));
}).add;


SynthDef(\moogbasstone2,{
	|out= 0 freq = 440 amp = 0.1 gate=1 attackTime= 0.2 fenvamount=0.5 cutoff= 1000 gain=2.0 pan=0.0|
	var osc, filter, env, filterenv;

	//alternative: richer source
	osc = Mix(Pulse.ar(freq.lag(0.05)*[1.0,1.001,2.0],Rand(0.45,0.5)!3,0.33));
	filterenv = EnvGen.ar(Env.adsr(attackTime,0.0,1.0,0.2),gate,doneAction:2);
	filter =  MoogFF.ar(osc,cutoff*(1.0+(fenvamount*filterenv)),gain);
	env = EnvGen.ar(Env.adsr(0.001,0.3,0.9,0.2),gate,doneAction:2);

	Out.ar(out,Pan2.ar((0.7*filter+(0.3*filter.distort))*env*amp,pan));

}).add;

SynthDef(\mrostinato,{
	|out= 0 freq = 440 amp = 0.1 gate=1 lforate = 10 lfowidth= 0.5 pan = 0.0|
	var lfo, pulse, filter, env;

	lfo = LFTri.kr(lforate,Rand(0,2.0)!3);
	pulse = Pulse.ar(freq*[1,1.01,0.5],lfo*lfowidth+0.5);
	env = EnvGen.ar(Env.adsr(0.01,0.05,0.5,0.1),gate,doneAction:2);

	Out.ar(out,Pan2.ar(Mix(pulse)*env*amp,pan));

}).add;

// =======
SynthDef(\situationsynth,{
	|out= 0 freq = 440 amp = 0.1 gate=1 cutoff=8000 rq=0.8 lfowidth=0.001 lforate= 3.3 pan=(-0.1)|
	var pulse, filter, env, filterenv, lfo;

	lfo = LFTri.kr(lforate,Rand(0,2.0)!2);
	pulse = Mix(Pulse.ar((((freq.cpsmidi)+[0,0.14])+(lfo*lfowidth)).midicps,[0.5,0.51]+(lfowidth*lfo)))*0.5;
	filterenv = EnvGen.ar(Env([0.0,1.0,0.3,0.0],[0.005,0.57,0.1],-3));
	filter =  RLPF.ar(pulse,100+(filterenv*cutoff),rq);
	env = EnvGen.ar(Env.adsr(0.002,0.57,1.0,0.3),gate,doneAction:2);

	Out.ar(out,Pan2.ar(filter*env*amp,pan));
}).add;

)

// Synths instantces
~prophetSynth = Pbind(
	\instrument,\prophet5pwmstrings,
	\midinote,Pseq([0,3,8,7,5,8,7,3]+48,inf),
	\dur,Pseq((0.5!8) ++ (0.25!8) ++ (2.0!8),inf),
	\lfowidth,Pn(Pseries(0.0,0.025,7),inf),
	\lforate,Pn(Pseries(2,1,11),inf),
	\rq,Pn(Pseries(0.9,-0.1,5),inf)
);

(
Pbind(
	\instrument,\prophet5pwmstrings,
	\midinote,Pseq([24,36,43,48, 43,48,36,36, 36,36,39,36, 31,31,31,31, 31,34,31,34],inf),
	\dur, Pseq([0.333, 0.3, 0.33333333, 1], 4),
).play;
)

~prophetSynth.play;
~prophetSynth.stop;


~moogbassSynth = Pfx(
	Pfx(
		Pmono(
			\moogbasstone2,
			\amp, 0.8,
			\midinote,Pseq([24,36,43,48, 43,48,36,36, 36,36,39,36, 31,31,31,31, 31,34,31,34],inf),
			\dur,0.25,
			\gain,Pn(Pseries(2,0.1,19),inf),
			\cutoff,Pstutter(3,Pn(Pseries(50,250,40),inf)),
			\attackTime,Pn(Pseries(0.0,0.01,30),inf),
			\fenvamount,Pstutter(4,Pn(Pseries(0.0,0.05,20),inf))
		),
		\delayeffect
	),
	\choruseffect
)

~moogbassSynth.play;

~mrostinatoSynth = PmonoArtic(
	\mrostinato,
	\octave,Pseq([3,3,4,4],inf),
	\scale,[0,2,3,5,7,8,10],
	\degree,Pstutter(16,Pseq([0,2,5,3],inf)),
	\dur,0.25,
	\lfowidth,Pstutter(8,Pn(Pseries(0.0,0.05,7),inf)),
	\lforate,Pstutter(5,Pn(Pseries(0.5,0.2,11),inf)),
	\pan,Pstutter(2,Prand([-0.5,-0.3,0.3,0.5],inf))
);

~mrostinatoSynth.play;

