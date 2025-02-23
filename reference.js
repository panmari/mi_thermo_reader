var $ = function(id) {
	return document.getElementById(id);
}
// Вывод в терминал
function log(data) {$('info').innerHTML=data};
function Clog(data) {$('info').innerHTML=data; console.log(data)};
var deviceName;
var devcnn = 0, redevcnn = 0;
const MAX_MEMORES = 65535; 
var memogetcont = MAX_MEMORES;
var deviceConnected = '';
$("LoadSamples").onchange = function() {
	memogetcont = parseInt($("LoadSamples").value);
	if(isNaN(memogetcont) || memogetcont > MAX_MEMORES) memogetcont = MAX_MEMORES;
	else if(memogetcont < 3) memogetcont = 3;
	$("LoadSamples").value = memogetcont;
}
function ShowConnect() {
	if(devcnn==0)  {
		$("butConnect").value = "Connect";
		$("butConnect").classList.remove("danger");} 
	else {
		$("butConnect").value = "Disconnect " +  deviceConnected; 
		$("butConnect").classList.add("danger");} 
	$("butConnect").disabled = false;
}
$("butConnect").onclick =  function() {
	$("butConnect").disabled = true;
	if(devcnn != 0) {$("butConnect").value = "Disconnect..."; disconnect();}
	else {$("butConnect").value = "Connect..."; connect();};
}
var localOffset = (new Date()).getTimezoneOffset() * 60000;
var show_on = 0;
// Буфер входящих данных
var datau = [];
var memo = [];
var gu;
function ShowGrfTH() {
	gu = new Dygraph(
		$("div_v"),
	    datau,
		{
			title: 'Stored data from: ' + deviceName,
			showRangeSelector: true,
			showRoller: true,
			rollPeriod: 0,
			xlabel: 'Date',
			ylabel: 'Temp(C&deg;)',
			y2label: 'H(%)',
			colors: ['green', 'blue'],
			series : { 'H(%)': { axis: 'y2' } },
			labels: ['Date', 'T(°C)', 'H(%)'],
			labelsDiv: $('labdiv'),
			legend: 'always',  // "follow"
			digitsAfterDecimal: 3,
		});
}
function ShowGrfU() {
	gu = new Dygraph(
		$("div_v"),
	    datau,
		{
			title: 'Battery voltage history from: ' + deviceName,
			showRangeSelector: true,
			showRoller: true,
			rollPeriod: 0,
			xlabel: 'Date',
			ylabel: 'V',
			colors: ['green'],
			labels: ['Date', 'V'],
			labelsDiv: $('labdiv'),
			legend: 'always',  // "follow"
			digitsAfterDecimal: 3,
		});
}
var renderChart = function() {
	gu.updateOptions({'file': datau});
}
function convertArrayOfObjectsToCSV(value){
	var result, ctr, keys, columnDelimiter, lineDelimiter, data;
	data = value.data || null;
	if (data == null || !data.length) {return null;}
	columnDelimiter = value.columnDelimiter || ';';
	lineDelimiter = value.lineDelimiter || '\n';
	keys = Object.keys(data[1]);
	result = '';
	if(deviceName != null)
		result += deviceName+lineDelimiter;
	result += 'Time-Data=(A2/86400)+25569'+columnDelimiter+'Temp'+columnDelimiter+'Humi'+columnDelimiter+'Vbat'+lineDelimiter;
	data.reduceRight(function(a, i) {
		ctr = 0;
		keys.forEach(function(key){
			if (ctr > 0) {
				result += columnDelimiter;
				result += i[key];
			} else
				result += i[key];
			ctr++;
		});
		result += lineDelimiter;
		return 1;
	}, 1);
	return result;
}
function download(data, filename, type) {
	var file = new Blob([data], {type: type});
	if (window.navigator.msSaveOrOpenBlob) { // ie10+
		window.navigator.msSaveOrOpenBlob(file, filename);
	} else { // ff, chrome
		url = URL.createObjectURL(file);
		let a = document.createElement("a");
		a.href = url;
		a.download = filename;
		document.body.appendChild(a);
		a.click();
		setTimeout(function(){document.body.removeChild(a);window.URL.revokeObjectURL(url);},0);
		URL.revokeObjectURL(url);
	}
}
$("butSave").onclick =  function() {
    download(convertArrayOfObjectsToCSV({data: memo}), 'data.csv', 'text/csv;charset=utf-8');
}
if(window.innerHeight > 320) $('div_v').style.height = (window.innerHeight-120) + 'px';
window.onresize = function(){
	if(window.innerHeight > 320) $('div_v').style.height = (window.innerHeight-120) + 'px';
//	if(gu) gu.resize();
//	$('div_v').style.width = (window.innerWidth-50) + 'px';
}
function hex(number, length) {
    var str = (number.toString(16)).toUpperCase();
    while (str.length < length) str = '0' + str;
    return str;
} 
function dump(ar, len) {
	let s = '';
	for(let i=0; i < len; i++) {
		s += hex(ar[i],2);
	}
	return s;
}
function ResponsePkt(value) {
	let ds = value.byteLength;
	let s = 'msg: ';
    for(let i=0; i < ds; i++) {
		s+=' '+hex(value.getUint8(i),2);
		if(i<ds-1) s+=',';
	}
	Clog(s);
}	
function show_graph() {
	if(memo.length > 1) {
		let hideldate = $('hideLoDate').checked;
		datau = new Array();
		if($('thvbat').checked) {
			memo.reduceRight(function(a, b)	{ 
			if(hideldate) {
				if(b[0] > 1609459200 && b[0] < 2255486400) datau.push([new Date(b[0]*1000.0+localOffset), b[3]/1000.0]); 
			} else datau.push([new Date(b[0]*1000.0+localOffset), b[3]/1000.0]); 
			return a+1;}, 1 );
		} else {
			memo.reduceRight(function(a, b)	{ 
			if(hideldate) {
				if(b[0] > 1609459200 && b[0] < 2255486400) datau.push([new Date(b[0]*1000.0+localOffset), b[1], b[2]]); 
			} else datau.push([new Date(b[0]*1000.0+localOffset), b[1], b[2]]);
			return a+1;}, 1 );
		}
		Clog('Loaded '+ datau.length + ' samples.')
		if(datau.length > 1) {
			if($('thvbat').checked) ShowGrfU();
			else ShowGrfTH();
			Clog('Loaded '+ datau.length + ' samples.')
		} else Clog('No samples!')
	}
}
$('hideLoDate').onchange = function() {show_graph();};
$('thvbat').onchange = function() {show_graph();};
//--BLE---------------------------------------
// Кэш объекта выбранного устройства
let deviceCache = null;
// Кэш объекта характеристики
var characteristicVTH = null;
function DevConnected() {
		devcnn = 1;
		redevcnn = 66;
		Clog('Device connected ok.');
		ShowConnect()
       	stage_read = 0;
}
// Запустить выбор Bluetooth устройства и подключиться к выбранному
function connect() {
	devcnn = 0;
	redevcnn = 0;
	return (deviceCache ? Promise.resolve(deviceCache) :
		requestBluetoothDevice()).
		then(device => connectDeviceAndCacheCharacteristic(device)).
		catch(error => {Clog(error); ShowConnect();});
}
// Запрос выбора Bluetooth устройства
function requestBluetoothDevice() {
	var deviceOptions = {optionalServices: [0xfe95, 0x181a, 0x1f10]};
	const namePrefix = $('namePrefix').value;
	if (namePrefix) {
		deviceOptions.acceptAllDevices = false;
		deviceOptions.filters = namePrefix.split(",")
			.map((x) => ({ namePrefix: x }));
	} else {
		deviceOptions.filters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz_#@!*0123456789';,.<>{}[]"
		.split("").map((x) => ({namePrefix:x}));
	}
	// deviceOptions.filters.services = [0xfe95, 0x181a, 0x1f10];
	Clog('Requesting bluetooth device...');
	return navigator.bluetooth.requestDevice(deviceOptions).
	then(device => {
		Clog('"' + device.name + '" bluetooth device selected');
		deviceName = device.name;
		deviceCache = device;
		deviceConnected = device.name;
		deviceCache.addEventListener('gattserverdisconnected', handleDisconnection);
		return deviceCache;
	});
}
// Обработчик разъединения
function handleDisconnection(event) {
	let device = event.target;
    ShowConnect();
	if(devcnn == 0 && ++redevcnn < 5) {
		Clog('"' + device.name + '" bluetooth device disconnected, trying to reconnect...');
		connectDeviceAndCacheCharacteristic(device).
		catch(error => Clog(error));};
}

var start_time;
// Подключение к определенному устройству, получение сервиса и характеристики
function connectDeviceAndCacheCharacteristic(device) {
  if (device.gatt.connected && characteristicVTH) {
  	return Promise.resolve(null);
  }
  Clog('Connecting to GATT server...');
  return device.gatt.connect().
	then(server => {
		Clog('GATT server connected, getting service...');
		return server.getPrimaryService(0x1F10);
	}).then(service => {
		Clog('Service found, getting characteristic...');
		return service.getCharacteristic(0x1F1F);
	}).
	then(characteristic => {
		Clog('Characteristic found');
		characteristicVTH = characteristic;
		devcnn = 1;
		ShowConnect();
		Clog('Start Notifications...');
		return characteristicVTH.startNotifications().
		then(_ => {
			Clog('Notifications Started');
			characteristicVTH.addEventListener('characteristicvaluechanged', event => {
			var value = event.target.value;
			let len = value.byteLength;
			if(len > 0) {
				let blkid = value.getUint8(0);
				if(blkid == 0x35) {
					ResponsePkt(value);
					if(len >= 13) {
						let cnt = value.getUint16(1, true);
						let tc = value.getUint32(3, true);
						let tm = value.getInt16(7, true) / 100.0;
						let hm = value.getUint16(9, true) / 100.0;
						let vb = value.getUint16(11, true);
						/* Slow speed on some devices!
						let dt = new Date(tc*1000);
						console.log('Memo '+((dt.toISOString().slice(0, -1)).replace('T',' ')).replace('.000','')+' - Vbat: '+vb+' mV , Temp: '+tm+'°C, Humi: '+hm+'%, Count: '+cnt);
						*/
						log('Read Count: '+cnt);
						memo.push([tc,tm,hm,vb]);
						show_on = 1;
					} else if(len >= 3) {
						console.log('Read count: '+ memo.length);
						console.log('Read time: ' + ((Date.now() - start_time)/1000).toFixed(3) + ' sec');
						let time = Date.now()/1000;
						time -= (new Date()).getTimezoneOffset() * 60;
						blk = new Uint8Array(5);
						blk[0] = 0x23;
						blk[1] = time & 0xff;
						blk[2] = (time >> 8) & 0xff;
						blk[3] = (time >> 16) & 0xff;
						blk[4] = (time >> 24) & 0xff;
						console.log("Send cmd Set DevTime ("+dump(blk, blk.length)+")...");
						characteristicVTH.writeValue(blk).then(_ => {
							console.log('Send new DevTime ok');
						});
					} else if(len == 2) {
						 memogetcont = value.getUint16(1, true);
					}
				} else if(blkid == 0x23 && len >= 4) {
					let time = value.getUint32(1,true);
					console.log('Device Time: 0x' + hex(time,8));
					let dt = new Date(time*1000);
					console.log('Device Date: '+(dt.toISOString().slice(0, -1)).replace('T',' '));
					disconnect();
				} else	if(blkid == 0x55) {
					if(len >= 12) {
						memo = new Array();
						datau = new Array();
/*						let av_meas_mem = value.getUint8(6) * 62.5 * value.getUint8(7) * value.getUint8(12);
						if(av_meas_mem == 0) av_meas_mem = 600;
						av_meas_mem /= 1000;
						console.log('Memos storage interval: ' + av_meas_mem + ' sec');
*/
						memogetcont = parseInt($("LoadSamples").value);
						if(isNaN(memogetcont) || memogetcont > MAX_MEMORES) memogetcont = MAX_MEMORES;
						else if(memogetcont < 5) memogetcont = 5;
						if(memogetcont == MAX_MEMORES)
							Clog('Send command "get-memo all samples"...');
						else
							Clog('Send command "get-memo '+memogetcont+' samples"...');
						start_time = Date.now();
						characteristicVTH.writeValue(new Uint8Array([0x35,memogetcont&0xff, (memogetcont>>8)&0xff,0,0]))
						.catch(error => {Clog(error); disconnect();});
					} else {
						Clog('Error device config!');
						disconnect();
					}
				} else ResponsePkt(value);
				}
			});
			DevConnected();
			Clog('Get device config...');
			setTimeout(function() {
				console.log('Send command "get config"...');
				characteristicVTH.writeValue(new Uint8Array([0x55])).catch(error => {log(error); disconnect();})
			}, 1500);
		  	return Promise.resolve(null);
		});
	});
}
// Отключиться от подключенного устройства
function disconnect() {
	devcnn = 0;
	redevcnn = 55;
	if (deviceCache) {
		Clog('Disconnecting from "' + deviceCache.name + '" bluetooth device...');
		if (deviceCache.gatt.connected) {
			if (characteristicVTH) {
				characteristicVTH.stopNotifications()
                .then(_ => {
					Clog('Notifications stopped');
					characteristicVTH = null;
				  	if (deviceCache.gatt.connected) {
						deviceCache.gatt.disconnect();
					}
					deviceCache.removeEventListener('gattserverdisconnected', handleDisconnection);
					deviceCache = null;
					Clog('Disconnected. Load '+memo.length+' samples.' );
					ShowConnect();
				})
				.catch(error => { Clog(error); 
					if (characteristicVTH) {
						characteristicVTH.removeEventListener('characteristicvaluechanged', handleCharacteristicValueChanged);
						characteristicVTH = null;
					}
					deviceCache.removeEventListener('gattserverdisconnected', handleDisconnection);
					deviceCache = null;
					ShowConnect();
				});
			}
		}
		if (show_on != 0) show_graph();
	}
	else
		Clog('"' + deviceCache.name + '" bluetooth device is already disconnected');
}