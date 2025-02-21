/// @function						VIMathWave(from, to, duration, offset);
/// @description					Waves between [from] and [to]. Takes [duration] seconds and is set of by [offset].
/// @param {Real} from				The value to start from.
/// @param {Real} to				The value to wave to.
/// @param {Real} duration			The duration for a complete wave in seconds.
/// @param {Real} offset			The offset.
function VIMathWave(from, to, duration, offset) {
	var w = (to - from) * 0.5;
	
	var time = current_time / 1000;
	return from + w + sin(((time + duration * offset) / duration) * (pi * 2)) * w;
};
