
---[[by lostangel 20100528]]
---[[edit 20110117 add interface readNextLine and readNextLineFromUTF8]]
--[[edit 20110216 add parse for 6cn]]
--[[edit 20110401 add hd2 parse for youku]]
--[[edit 20110409 edit readuntil series function for one line bilibili source html]]
--[[edit 20110418 for forbidden 6cn video parse]]
--[[edit 20110704 for bili.tv,acfun.tv]]
--[[edit 20110729 for automate download tudou highest quality video]]
--[[edit 20110819 for youku new parse key]]
require "bit"

function getACFPV ( str_url, str_servername)
	if str_servername == nil then
		str_servername = "acfun.tv";
	end
	if string.find(str_url, "acfun.cn",1,true)~=nil or string.find(str_url, "124.228.254.229")~=nil or string.find(str_url, str_servername, 1, true)~=nil or string.find(str_url, "acfun.tv",1,true)~=nil
	then
		return 1;--ACFPV_NEW
		--return 65535;
	elseif string.find(str_url, "bilibili.us",1,true)~=nil or string.find(str_url, "bilibili.tv",1,true)~=nil
	then
		return 3;--BIRIBIRIPAD
	elseif string.find(str_url, "mikufans.cn",1,true)~=nil  or string.find(str_url, "danmaku.us", 1, true)~=nil
	then
		if string.find(str_url, "bilibili", 1,true)~=nil
		then
			return 3;--BIRI
		else
			return 4;--mikufans
		end
	elseif string.find(str_url, "nicovideo.jp", 1, true)~=nil
	then
		return 2;--NICOP_2009
	elseif string.find(str_url, "nico.galstars.net", 1, true)~=nil
	then
		return 2;
	end
	--2:NICOP_2009
	--0:ACFPV_ORI
	--65535:NOTFLV
	--other:reserved
	return 0;

end

--[[read nextline from file]]
function readNextLine( file )
	local str_line = "";
	str_line = file:read("*l");
	return str_line;
end

--[[read from file until counter str_tag. return the last read line.]]
function readUntil( file, str_tag , str_old)
	if str_old ~= nil then
		if string.find(str_old, str_tag, 1, true)~=nil then
			return str_old;
		end
	end
	local str_line = "";
	repeat
		str_line = file:read("*l");
		print(str_line);
	until str_line==nil or string.find(str_line, str_tag, 1, true)~=nil
	return str_line;
end

--[[read from file until counter str_tag. every line read is attached to str_ori and return the joined str.]]
function readIntoUntil(file, str_ori, str_tag, str_old)
	if str_old ~= nil then
		if string.find(str_old, str_tag, 1, true)~=nil then
			return str_old;
		end
	end
	local str_line = "";
	while str_line~=nil and str_ori~=nil and string.find(str_ori, str_tag, 1, true)==nil
	do
		str_line = file:read("*l");
		if str_line~=nil
		then
			str_ori = str_ori..str_line;
		end
	end
	return str_ori;
end


--[[read next line from file .]]
function readNextLineFromUTF8( file )
	local str_line = "";

	local tmp_line = file:read("*l");
	if tmp_line == nil then
		return;
	end
	str_line = utf8_to_lua(tmp_line);

	return str_line;
end

--[[read from file until counter str_tag. return the last read line.]]
function readUntilFromUTF8( file, str_tag ,str_old)
	if str_old ~= nil then
		if string.find(str_old, str_tag, 1, true)~=nil then
			return str_old;
		end
	end
	local str_line = "";
	repeat
		local tmp_line = file:read("*l");
		if tmp_line == nil then
			return;
		end
		str_line = utf8_to_lua(tmp_line);
		print(str_line);
		--dbgMessage(str_line);
	until str_line==nil or string.find(str_line, str_tag, 1, true)~=nil
	return str_line;
end

--[[read from file until counter str_tag. every line read is attached to str_ori and return the joined str.]]
function readIntoUntilFromUTF8(file, str_ori, str_tag, str_old)
	if str_old ~= nil then
		if string.find(str_old, str_tag, 1, true)~=nil then
			return str_old;
		end
	end
	local str_line = "";
	while str_line~=nil and str_ori~=nil and string.find(str_ori, str_tag, 1, true)==nil
	do
		local tmp_line = file:read("*l");
		if tmp_line == nil then
			return;
		end
		str_line = utf8_to_lua(tmp_line);
		if str_line~=nil
		then
			str_ori = str_ori..str_line;
		end
	end
	return str_ori;
end

--[[substring after str_tag in str, from index]]
function getAfterText( str, str_tag , index)
	if index==nil then
		index = 1;
	end
	if str==nil then
		return nil;
	end

	local sb, tb = string.find(str, str_tag, index, true);

	if tb==nil
	then
		return nil;
	end

	return string.sub(str, tb+1);


end

--[[substring in str, between str_tagb and str_tage.]]
function getMedText(str, str_tagb, str_tage, index)
	if index==nil then
		index = 1;
	end
	if str==nil then
		return nil;
	end

	local sb, tb = string.find(str, str_tagb, index, true);

	if tb==nil
	then
		return nil;
	end
	local se, te = string.find(str, str_tage, tb+1, true);

	if se~=nil
	then
		return string.sub(str, tb+1, se-1), se;
	else
		return nil;
	end
end

--[[substring in str, between str_tagb and the one in (str_tage1, str_tage2) which is fronter.]]
function getMedText2end(str, str_tagb, str_tage1, str_tage2, index)
	if index==nil then
		index = 1;
	end
	print(str, str_tagb);
	if str==nil then
		return nil;
	end
	local sb, tb = string.find(str, str_tagb, index, true);
	print(sb, tb);
	if tb==nil
	then
		return nil;
	end
	local se1, te1 = string.find(str, str_tage1, tb+1, true);
	local se2, te2 = string.find(str, str_tage2, tb+1, true);
	print(sb, tb, se1, te1, se2, te2);
	--local str_print = "";
	--str_print= string.format("sb: %d, tb: %d; se1: %d, te1: %d", sb, tb, se1, te1);--, se2, te2);
	--dbgMessage(str_print);
	if se1~=nil and se2~=nil
	then
		if se1<se2
		then
			se = se1;
		else
			se = se2;
		end
	elseif se1~=nil
	then
		se = se1;
	elseif se2~=nil
	then
		se = se2;
	else
		se = nil;
	end

	if se~=nil
	then
		--dbgMessage(string.sub(str, tb+1, se-1));
		return string.sub(str, tb+1, se-1),se;
	else
		return nil;
	end
end

--decode urls
function decodeUrl(str_url)
	local str_new_url = str_url;
	if str_new_url == nil then
		return str_new_url;
	end
	str_new_url=string.gsub(str_new_url, "%%2B", "+");
	str_new_url=string.gsub(str_new_url, "%%20", " ");
	str_new_url=string.gsub(str_new_url, "%%2F", "/");
	str_new_url=string.gsub(str_new_url, "%%3F", "?");

	str_new_url=string.gsub(str_new_url, "%%23", "#");
	str_new_url=string.gsub(str_new_url, "%%26", "&");
	str_new_url=string.gsub(str_new_url, "%%3D", "=");
	str_new_url=string.gsub(str_new_url, "%%3A", ":");
	str_new_url=string.gsub(str_new_url, "%%40", "@");
	str_new_url=string.gsub(str_new_url, "%%25", "%%");

	--dbgMessage(str_url);
	--dbgMessage(str_new_url);
	return str_new_url;
end

--encode urls
function encodeUrl(str_url)
	local str_new_url = str_url;
	if str_new_url == nil then
		return str_new_url;
	end
	str_new_url=string.gsub(str_new_url, "%%", "%%25");
	str_new_url=string.gsub(str_new_url, "+", "%%2B");
	str_new_url=string.gsub(str_new_url, " ", "%%20");
	str_new_url=string.gsub(str_new_url, "/", "%%2F");
	str_new_url=string.gsub(str_new_url, "?", "%%3F");

	str_new_url=string.gsub(str_new_url, "#", "%%23");
	str_new_url=string.gsub(str_new_url, "&", "%%26");
	str_new_url=string.gsub(str_new_url, "=", "%%3D");
	str_new_url=string.gsub(str_new_url, ":", "%%3A");
	str_new_url=string.gsub(str_new_url, "@", "%%40");
	return str_new_url;
end

--cut <> from text
function cutTags(str_url)
	local str_new_url = str_url;
	local istart = string.find(str_new_url, "<", 1, true);
	while istart ~= nil do
		local iend = string.find(str_new_url, ">", istart, true);
		if iend == nil then
			break;
		end
		local str_tmp_url = string.sub(str_new_url, 1, istart-1) .. string.sub(str_new_url, iend+1);
		str_new_url = str_tmp_url;
		istart = string.find(str_new_url, "<", 1, true);
	end
	return str_new_url;
end


--foreign link site
fls={};
fls["realurl"]=0;
fls["sina"]=1;
fls["qq"]=2;
fls["youku"]=3;
fls["tudou"]=4;
fls["6cn"]=5;


--BOOLEAN
SUCCESS = 1;
FAILURE = 0;


--[[read real urls from sina through vid]]
-- See: http://agonix.5d6d.com/archiver/tid-47.html
-- Example: http://v.iask.com/v_play.php?vid=15830701
--          http://video.sina.com.cn/v/b/15830701-1264371947.html
--          http://p.you.video.sina.com.cn/player/outer_player.swf?auto=1&vid=15830701&uid=1264371947
function getRealUrls (str_id, str_tmpfile, pDlg)
	local tbl_urls = {};
	local tbl_durations = {};
	local index = 0;

	local str_dynurl = "http://v.iask.com/v_play.php?vid="..str_id;
	if pDlg~=nil then
		sShowMessage(pDlg, '���ڶ�ȡת��ҳ��..');
	end
	--str_tmpfile = "C:\\tempacfun.html";
	--dbgMessage(str_tmpfile);
	--dbgMessage(str_dynurl);
	local re = dlFile(str_tmpfile, str_dynurl);
	--dbgMessage("dl dynurl end.");
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls, tbl_durations;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end

	local str_line = "";
	while str_line~=nil
	do
		str_line = readUntil(file, "<length>");
		str_line = readIntoUntil(file, str_line, "</length>");
		if str_line~=nil and string.find(str_line, "<length>")~=nil
		then
			local str_index = string.format("%d",index);
			tbl_durations[str_index] = getMedText(str_line, "<length>", "</length>");
			print(tbl_durations[str_index]);
			--index = index+1;
		end
		str_line = readUntil(file, "<url>");
		str_line = readIntoUntil(file, str_line, "</url>");
		if str_line~=nil and string.find(str_line, "<url>")~=nil
		then
			local str_index = string.format("%d",index);
			tbl_urls[str_index] = getMedText(str_line, "<url><!\[CDATA\[", "\]\]></url>");
			print(tbl_urls[str_index]);
			index = index+1;
		end
	end
	io.close(file);
	return index, tbl_urls, tbl_durations;
end


function getTot_QQ ( str_id, int_mod)
	local _loc_4 = 0;
	local _loc_5 = 0;
	while _loc_4 < string.len(str_id)
	do
		local _loc_6 = string.byte(str_id, _loc_4+1);
		_loc_5 = _loc_5*32 + _loc_5 + _loc_6;
		if _loc_5 >= int_mod then
			_loc_5 = _loc_5%int_mod;
		end
		_loc_4 = _loc_4+1;
	end
	return _loc_5;
end

function getDefaultFlvUrl_QQ (str_id)
	local _loc_2 = 4294967295 +1;
	local _loc_3 = 10000*10000;
	local _loc_4 = getTot_QQ(str_id, _loc_2)%_loc_3;
	--return "http://v.video.qq.com/" .. string.format("%d",_loc_4) .. "/" .. str_id .. ".flv";
	--return "http://vsrc.store.qq.com/" .. str_id .. ".flv";
	return "http://video.store.qq.com/" .. string.format("%d",_loc_4) .. "/" .. str_id .. ".flv";

end
--[[read real urls from qq through vid]]
function getRealUrls_QQ (str_id, str_tmpfile, pDlg)
	local tbl_urls = {};
	local index = 0;

	--[[local str_prefetchcookie = "http://cgi.video.qq.com/v1/videopl?v=" .. str_id;
	local re_cookie = dlFile(str_tmpfile, str_prefetchcookie);
	if re_cookie~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	end]]
--[[
	local str_dynurl = "http://video.qq.com/v1/vstatus/geturl?ran=0%2E18432170618325472&vid="..str_id.."&platform=1&otype=xml";
	--dbgMessage(str_dynurl);
	if pDlg~=nil then
		sShowMessage(pDlg, '���ڶ�ȡת��ҳ��..');
	end

	local re = dlFile(str_tmpfile, str_dynurl);
	--dbgMessage("dlok");
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end

	local str_line = "";
	while str_line~=nil
	do
		str_line = readUntil(file, "<url>");
		str_line = readIntoUntil(file, str_line, "</url>");
		--dbgMessage(str_line);
		if str_line~=nil and string.find(str_line, "<url>")~=nil
		then
			local str_index = string.format("%d",index);
			if string.find(str_line, "<url><!\[CDATA")~=nil then
				tbl_urls[str_index] = getMedText(str_line, "<url><!\[CDATA\[", "\]\]></url>");
			else
				tbl_urls[str_index] = getMedText(str_line, "<url>", "</url>");
			end
			--dbgMessage(tbl_urls[str_index]);
			index = index+1;
		end
	end
	io.close(file);

]]


--[[	if index==0 then
		--dbgMessage(getDefaultFlvUrl_QQ(str_id));
		local str_index = string.format("%d",index);
		tbl_urls[str_index] = getDefaultFlvUrl_QQ(str_id);
		index = index+1;
	end
]] --comment 20101120
	local str_dynurl = "http://vv.video.qq.com/geturl?vid=".. str_id.."&otype=xml&platform=1&ran=0%2E9652906153351068";

	if pDlg~=nil then
		sShowMessage(pDlg, '���ڶ�ȡת��ҳ��..');
	end

	local re = dlFile(str_tmpfile, str_dynurl);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end

	local str_line = readUntil(file, "<url>");
	--dbgMessage(str_line);

	local str_realurl = getMedText(str_line, "<url>", "</url>");

	io.close(file);

	if str_realurl == nil then
		str_realurl = getDefaultFlvUrl_QQ(str_id);
	end

	if index==0 then
		local str_index = string.format("%d",index);
		tbl_urls[str_index] = str_realurl;
		index = index+1;
	end

	return index, tbl_urls;

end

--[[read real urls from youku through vid]]
function getRealUrls_youku (str_id, str_tmpfile, pDlg)
	local tbl_urls = {};
	local index = 0;

	local str_dynurl = "http://v.youku.com/player/getPlayList/VideoIDS/"..str_id.."...ezone/+08/version/5/source/video?password=&ran=1527&n=3";
	--dbgMessage(str_dynurl);
	if pDlg~=nil then
		sShowMessage(pDlg, '���ڶ�ȡת��ҳ��..');
	end

	local re = dlFile(str_tmpfile, str_dynurl);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end

	local str_line = file:read("*l");
	--str_line = '{"data":[{"tt":"0","ct":"c","cs":"2043|2053","logo":"http:\/\/g1.ykimg.com\/11270F1F464B2FB3A0C63F0051AE550CE7D610-8E8B-4C0D-58CB-D44E6653E344","seed":5564,"tags":["\u5927\u72ec\u88c1\u8005","\u6b27\u7f8e\u7535\u5f71","\u5353\u522b\u6797"],"categories":"96","videoid":"4579646","username":"pk\u6b27\u7f8e\u7535\u5f71","userid":"5353045","title":"\u5927\u72ec\u88c1\u8005","key1":"b341af1d","key2":"fbd05fdf2515d7b7","seconds":"9272.31","streamfileids":{"flv":"59*60*59*59*59*52*15*57*59*59*37*58*52*32*58*60*51*59*52*58*32*18*59*59*62*15*51*18*62*62*56*18*62*58*59*52*57*33*63*60*56*59*37*63*52*33*58*32*63*60*34*32*1*63*49*56*34*15*49*51*58*33*59*18*33*52*"},"segs":{"flv":[{"no":"0","size":"11053775","seconds":"392"},{"no":"1","size":"11020457","seconds":"391"},{"no":"2","size":"11073594","seconds":"393"},{"no":"3","size":"11033395","seconds":"391"},{"no":"4","size":"11036282","seconds":"394"},{"no":"5","size":"11096501","seconds":"395"},{"no":"6","size":"11120825","seconds":"395"},{"no":"7","size":"11068181","seconds":"393"},{"no":"8","size":"11095678","seconds":"393"},{"no":"9","size":"11122456","seconds":"394"},{"no":"10","size":"11104042","seconds":"396"},{"no":"11","size":"11076731","seconds":"393"},{"no":"12","size":"11089666","seconds":"394"},{"no":"13","size":"11138935","seconds":"394"},{"no":"14","size":"11115464","seconds":"394"},{"no":"15","size":"11106212","seconds":"395"},{"no":"16","size":"11075559","seconds":"393"},{"no":"17","size":"10971026","seconds":"394"},{"no":"18","size":"10994588","seconds":"390"},{"no":"19","size":"11031881","seconds":"390"},{"no":"20","size":"10974867","seconds":"393"},{"no":"21","size":"10997277","seconds":"392"},{"no":"22","size":"11068274","seconds":"392"},{"no":"23","size":"6505963","seconds":"230"}]},"streamsizes":{"flv":"260971629"},"streamtypes":["flvhd"],"streamtypes_o":["flvhd"]}],"user":{"id":"55862138"},"controller":{"search_count":true,"mp4_restrict":1,"stream_mode":1,"share_disabled":false,"download_disabled":false}}';
	--dbgMessage(str_line);

	--local _, _, seed, key1,key2,fileID, flv_no= string.find(str_line,
	--	'"seed":(%d+),.+"key1":"(%w+)","key2":"(%w+)",.+"streamfileids":{"flv":"([0-9%*]+)"},.+{"no":"(%d+)",');
	local _, _, seed, key1,key2,fileposfix,fileID, flv_no= string.find(str_line,
		'"seed":(%d+),.+"key1":"(%w+)","key2":"(%w+)",.+"streamfileids":{"(%w+)":"([0-9%*]+)".+"%4":%[[^%]]*{"no":"*(%d+)"*');
		--'"seed":(%d+),.+"key1":"(%w+)","key2":"(%w+)",.+"streamfileids":{"(%w+)":"([0-9%*]+)".+"%4":%[[^%]]*{"no":');
	--local _, _, fileposfix, fileID, flv_no = string.find(str_line,
	--	'"streamfileids":{"(%w+)":"([0-9%*]+)".+"%1":%[{"no":"(%d+)"');
	if seed==nil or key1==nil or key2==nil or fileID==nil or flv_no==nil then
		io.close(file);
		return index, tbl_urls;
	end
	io.close(file);


	--[[read key, seed, fileID, flv_no ok]]
	seed = tonumber(seed);
	if seed==nil then
		return;
	end

	--getmixstring
	local str_mixed="";
	local str_source="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890";
	local int_len = string.len(str_source);
	for i=1, int_len, 1 do
		seed = (seed*211+30031)%65536;
		local index_chr = math.floor(seed/65536*string.len(str_source))+1;
		local chr = string.sub(str_source,index_chr,index_chr);
		str_mixed = str_mixed..chr;
		local ori_source = str_source;
		if chr=='.' or chr=='\\' then
			chr = '%'..chr;
		end
		str_source = string.gsub(str_source, chr,"");
	end

	--get realID
	local tbl_ids={};
	local str_realID = "";
	for v in string.gmatch(fileID, "(%d+)%*") do
		str_realID = str_realID..string.sub(str_mixed, v+1,v+1);
	end

	--get key
	local key = key2..string.format("%x",bit.bxor(tonumber(key1, 16), 0xA55AA5A5));

	--get sid
	local sid = tostring(os.time())..string.format("%d%d%d",
		math.random(899)+100,
		math.random(999)+1000,
		math.random(9000)+1000);
	--dbgMessage(sid);

	--dbgMessage(key);
	flv_no = tonumber(flv_no);

	for i=0, flv_no, 1 do
		local str_index_flvno = string.format("%02X" ,index);
		--dbgMessage(str_index);
		local str_index = string.format("%d",index);
--
		--for new youku key parse 20110819 lostangel
		str_regkey = '"segs":{"'.. fileposfix ..'":%[[^%]]*{"no":"?'.. str_index ..'"?[^}]*"k":"(%w+)"[^%]]*%]';
		--str_regkey = '"segs":{.*(?!"'..fileposfix ..'")"'.. fileposfix ..'":%[[^%]]*{"no":"?'.. str_index ..'"?[^}]*"k":"(%w+)"[^%]]*%]';
		--str_regkey = '"segs":{"flv":%[{"no":0,"size":"%d+","seconds":"%d+","k":"(%w+)"}';
		--dbgMessage(str_regkey);
		--dbgMessage(str_line);
		--dbgMessage(fileposfix);
		local _, _, tmpkey = string.find(str_line, str_regkey);
		--dbgMessage(tmpkey);
		key = tmpkey;
		--end

		str_realID = string.sub(str_realID, 1, 8)..str_index_flvno..string.sub(str_realID, 11);
		local filetype = fileposfix;
		if filetype == 'hd2' then
			filetype = 'flv';
		end
		tbl_urls[str_index] = "http://f.youku.com/player/getFlvPath/sid/"
			..sid
			.."_"
			..str_index_flvno
			.."/st/"
			..filetype
			.."/fileid/"
			..str_realID
			.."?K="
			..key
			.."&myp=0&ts=105";
		if fileposfix == 'hd2' then
			tbl_urls[str_index] = tbl_urls[str_index] .. '&hd=2';
		end
		index = index+1;
		--dbgMessage(tbl_urls[str_index]);
	end




	return index, tbl_urls;
end


--[[read real urls from tudou through vid]]
function getRealUrls_tudou (str_id, str_tmpfile, pDlg)
	local index = 0;
	local tbl_urls= {};

	--dbgMessage(str_id);

	local str_oriurl = "http://www.tudou.com/programs/view/" .. str_id .. "/";

	if pDlg~=nil then
		sShowMessage(pDlg, '���ڶ�ȡת��ҳ��..');
	end
	local re = dlFile(str_tmpfile, str_oriurl);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end

	local str_line = readUntil(file, "document.domain");
	local str_line_end = readIntoUntil(file , str_line, "</script>");
	--dbgMessage(str_line_end);
	local iid = getMedText(str_line_end, "iid = ", ",");

	--read iid ok closefile
	io.close(file);

	local str_preurl = "http://v2.tudou.com/v?st=1%2C2%2C3%2C4%2C99&it=" .. iid;

	re = dlFile(str_tmpfile, str_preurl);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end


	str_line = file:read("*l");
	--local _, _, str_v_realurl= string.find(str_line,
	--		"<[ab]><f [^>]+>([^<]+)</f>.*</[ab]>");
	--	--dbgMessage(str_v_realurl);

	local str_v_realurl = nil;
	local brt = 0;
	while str_line ~= nil
	do
		local _, _, str_v_realurl_tmp = string.find(str_line,
			"<f [^>]+>([^<]+)</f>");
		local _, _, str_brt = string.find(str_line,
			'<f [^>]+brt="(%d+)"[^>]*>[^<]+</f>');
		if str_brt~=nil and str_v_realurl_tmp ~=nil then
			local int_brt = tonumber(str_brt);
			if int_brt > brt then
				brt = int_brt;
				str_v_realurl = str_v_realurl_tmp;
			end
		end
		str_line = getAfterText(str_line, '</f>');
		--dbgMessage(str_line);
	end
	--dbgMessage(str_v_realurl);
	--read urlok close file
	io.close(file);


	local str_index = string.format("%d",index);
	tbl_urls[str_index] = str_v_realurl;
	index = index+1;



	return index, tbl_urls;
end

--[[read real urls from 6cn through vid]]
function getRealUrls_6cn (str_id, str_tmpfile, pDlg)
	local index = 0;
	local tbl_urls= {};

	--dbgMessage(str_id);

	local str_oriurl = "http://6.cn/v72.php?vid=" .. str_id;

	if pDlg~=nil then
		sShowMessage(pDlg, '���ڶ�ȡת��ҳ��..');
	end
	local re = dlFile(str_tmpfile, str_oriurl);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return index, tbl_urls;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡת��ҳ��ɹ������ڷ���..');
		end
	end

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, 'ת��ҳ���ȡ����');
		end
		return;
	end

	local str_line = readUntil(file, "<file>");
	local str_line_end = readIntoUntil(file , str_line, "</file>");
	--dbgMessage(str_line_end);

	local str_v_realurl = getMedText(str_line_end, "<file>", "</file>");

	--read str_v_realurl ok closefile
	io.close(file);


	--generate key
	local _loc1 = os.time();
	math.randomseed(_loc1);
	_loc1 = _loc1+123456;
	local key3 = 1000000000 + math.random(1000000000);
	local key4 = 1000000000 + math.random(1000000000);
	local key1 = 0;
	local key2 = 0;
	local _loc2 = math.random(100);
	if _loc2>50 then
		key1 = math.abs(bit.bxor(math.floor(_loc1/3),key3));
		key2 = math.abs(bit.bxor(math.floor(_loc1*2/3),key4));
	else
		key1 = math.abs(bit.bxor(math.floor(_loc1*2/3),key3));
		key2 = math.abs(bit.bxor(math.floor(_loc1/3),key4));
	end

	if str_v_realurl == nil then
		str_v_realurl = "";
	else
		str_v_realurl = str_v_realurl .. "?start=0&key1=" .. key1 .. "&key2=" .. key2 .. "&key3=" .. key3 .. "&key4=" .. key4;
	end


	--dbgMessage(str_v_realurl);

	local str_index = string.format("%d",index);
	tbl_urls[str_index] = str_v_realurl;
	index = index+1;



	return index, tbl_urls;
end

--[[copy table]]
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--[[Sleep xxx ms]]
function time_sleep(int_millisecond, int_random_max)
	local tic = os.time();
	local int_random = 0;
	if int_random_max~=nil then
		math.randomseed(tic);
		int_random = math.random(int_random_max);
	end
	local t_diff = (int_millisecond+int_random)/1000;
	while true do
		local toc = os.time();
		if os.difftime(toc, tic)>=t_diff then
			break;
		end
	end
end



