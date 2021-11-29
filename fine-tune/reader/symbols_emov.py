seen_speakers = ["Neutral", "Amused", "Angry", "Sleepy", "Disgusted"]
phone_list = ['pau', 'iy', 'aa', 'ch', 'ae', 'eh', 
 'ah', 'ao', 'ih', 'ey', 'aw', 
 'ay', 'ax', 'er', 'ng', 
 'sh', 'th', 'uh', 'zh', 'oy', 
 'dh', 'y', 'hh', 'jh', 'b', 
 'd', 'g', 'f', 'k', 'm', 
 'l', 'n', 'p', 's', 'r', 
 't', 'w', 'v', 'ow', 'z', 
 'uw', 'SOS/EOS']

ph2id = {ph:i for i, ph in enumerate(phone_list)}
id2ph = {i:ph for i, ph in enumerate(phone_list)}
sp2id = {sp:i for i, sp in enumerate(seen_speakers)}
id2sp = {i:sp for i, sp in enumerate(seen_speakers)}
