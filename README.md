# MUSSORGSAL

This is/will be a "fully-functional mock-up" of a digital audio workstation, or DAW, for short, implemented in [LÖVE](http://www.love2d.org).

*Note that this requires either the latest nightly, or the upcoming 0.11 version of LÖVE, that added support for queue-able sources!*

### Features *(abridged)*

#####Instruments

* A basic sampler.
* A basic synth.

#####Effects

* A majority of effects from various tracker formats.
* "Mixer"
* Filters
* ADSR (Envelopes)
* Visualizers

#####Views

* DSP Graph (Instruments & Effects)
* Editors (Numerical/Tracker, Piano-roll, Score/Sheet, Raw)
* Arranger (2 Dimensional)
* Log window (Also chat window)

### Command-line flags

`-s` Runs a headless server, good if one wants to host a server remotely; no CLI input though.

### License

MUSSORGSAL is licensed under the **ISC License**.

### Features (*tl;dr*)

This program has two main goals:

* to combine the features of various, vastly different DAWs.
* to enable (online) collaboration between people, and OS-es.

#####Collaboration

* Either WAN, LAN or on the same device.
(The last may be a bit difficult.)
* Servers can hold only one active session at once.
(Same with clients being able to have one project open at a time, actually.)
* Servers can use either a black-list or a white-list to allow or deny clients access to the sessions.
* Clients can be servers as well.
* Automatic adaptive locking of currently edited objects.
* Locks can be set beforehand as well, if one intends to work on a part for a longer amount of time.
* Integrated IRC-like chat; one public channel, one private channel per 2-peer groups. Nickname, inline object reference support.
* Eye candy in the form of seeing collaborators' active objects, edit cursors, mouse cursors and their playback states. (toggle-able)
* Unlike a certain other collaborative DAW, the GUI/view/interface is local, not global. (Though they may have fixed that already...)
* Sessions can be left and rejoined later; the server will try to sync the offline project with the online session, merging changes both ways, if it can. 

#####Editors

* All editor types are just visual interfaces accessing the underlying data in various ways.
(Some do need to store some editor-specific data though.)
* More than one editor can be open at any time; even for the same pattern.
* Tracker ticks are equated with MIDI PPQ.
* Tracker rows are equated with MIDI PPQ and Time Signature.
* Key signature applicable to Score view and possibly Piano roll view.
* Chords / Scales applicable to Piano roll view, and possibly Score view.
* The Piano roll and Score views defaults to separating data per-instrument. Ghost notes can be toggled for the former.
* The Tracker view, by default, shows all tracks in a pattern; each track shows notes, instrument numbers and a number of effect columns at a time. (Filterable)
* Individual notes have various "Aftertouch"-like parameters, that are most easily editable in the Tracker view.
* Note lengths are fairly straightforward in Piano roll view, some "blending" can happen in Score view due to the nature of Modern Musical Notation; Tracker view either denotes note lengths with a note off symbol (==), a note cut symbol (^^), or with a new note (that's not a glide or anything similar).
* Tracker view tracks are generic; any instrument can reside within them; notes save which track they're in in this view.
* Score view may have a MIDI-channel-esque separation that would grant more fine-tuned note separation along different staves; interoperability with Piano roll based on 16 colors...
* The raw editor would just list note (and other parameter) properties, filterable.
* The 2 "graphical" editors (Score view notwithstanding) should support editing automation curves as well, whenever.

#####DSP Graph

* Initially a simple hard-coded [I]=[F]=[F]=[M]-[V]-[O] chain, where I,F,M,V,O are instrument, effect, mixer, visualizer, out respectively.
* Later, the **signal paths** will be user-definable.
* Also later, custom instruments and effects.

#####Instruments

* The **sampler** is able to cross-fade between two arbitrary waveforms.
* The **generator** supports all the basic waveforms, some more esoteric ones, filtered noise generators, and can even be given a custom function.
* **Voices** are active from a note-on until a note-cut. While a note-off also means that new note input is safe in the Tracker view, the voice still plays the note's release envelope, if present; otherwise the two are equivalent.
* **ADSR envelopes** are per-voice, per-((per-voice)-parameter).
* Most **tracker effects** are per-voice also, after the ADSR; the ones modifying "global" or non-instrument related pattern state are handled separately.
* **Filters** act on the combined output of instruments.
* **Visualizers** will, at first, be implemented only after the mixer component.

#####Arranger

* Two-dimensional.
* Arranger tracks are also generic, tracks can hold arbitrary clips.
* Pattern **clips (instances)** can't overlap, there's a reason why this is 2 dimensional...
* Having more than one of the same global parameter automated at the same place in time will use the vertically lowest clip's values.
* Instances can be resized from both ends. Above mentioned granularity restrictions apply here as well.
* Loop points, position jumps implemented here. Pattern breaks are non-existent, since they can be simulated by resizing an instance. Loop points may have additional parameters, like delay time, playback direction.

#####Misc. Functionality

* Support for importing various modules. (The 4 usual suspects, initially; No exporting though.)
* Not really needed unless this would support 3rd party plugins (VST,DX,AU,LADSPA,...), but **freezing** patterns, and sending them as audio clips through to other collaborators would be a necessity in that case.
(Otherwise the use-case would be lessening the CPU usage.)
* Similarly as above, **bouncing** would be needed if a client's RAM could not bear keeping everything loaded at once. (Shouldn't happen, even with audio clips, since LÖVE supports partial decoding from disk.)