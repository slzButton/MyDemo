var audio = document.getElementById('audio');
var btnPlay = document.getElementById('btnStart');
//开始播放
document.getElementById('btnStart').addEventListener('tap', function() {
		if(this.className == 'mus-start') {
			this.className = 'mus-pause';
			audio.play(); // 这个就是播放
		} else {
			this.className = 'mus-start';
			audio.pause(); // 这个就是暂停
		}
	})
	//上一首
document.getElementById('btnPrev').addEventListener('tap', function() {
		prev();
	})
	//下一首
document.getElementById('btnNext').addEventListener('tap', function() {
		next();
	})
	//切换单曲循环、列表循环
document.getElementById('btnLoop').addEventListener('tap', function() {
		if(this.className == 'mus-single') {
			this.className = 'mus-loop';
			audio.loop = false; //列表循环
		} else {
			this.className = 'mus-single';
			audio.loop = true; //单曲循环
		}
	})
	//循环播放下一首
document.getElementById("audio").addEventListener('ended', function() {
	next();
})
document.getElementById("local").addEventListener('tap', function() {
	musics=localMusics;
	$('#onlineList').hide();
	$('#localList').show();
})
document.getElementById("online").addEventListener('tap', function() {
	musics=onlineMusics;
	$('#onlineList').show();
	$('#localList').hide();
})

var pastime = document.getElementById("pastime");
var interval = setInterval(function() {
	var widthline = Math.round(audio.currentTime) / Math.round(audio.duration) * 100;
	mui("#pastime").progressbar().setProgress(widthline);
}, 500);

Mock.mock('http://phone.cn', {
	"online": [{
		"name": "你猜猜",
		"url": "http://192.168.5.184:8080/version"
	}],
	"locality": [{
		"name": "yangcong",
		"url": "http://192.168.5.184:8080/yangcong.mp3"
	}]
});
var musics = [];
var onlineMusics = [];
var localMusics = [];
var index = 0;
$.ajax({
	url: 'http://phone.cn',
	dataType: 'json',
	success: function(data) {
		if(data.online.length > 0) {
			onlineMusics = data.online;
			musics=onlineMusics;
			for(var i = 0, len = data.online.length; i < len; i++) {
				$('#onlineList').append('<li class="mui-table-view-cell" data-index="' +
					i + '"data-src = "' + data.online[i].url + '"data-name="' + data.online[i].name + '">' +
					data.online[i].name + '</li>');
			}
		}
		if(data.locality.length > 0) {
			localMusics = data.locality;
			for(var i = 0, len = data.locality.length; i < len; i++) {
				$('#localList').append('<li class="mui-table-view-cell" data-index="' +
					i + '"data-src = "' + data.locality[i].url + '"data-name="' + data.locality[i].name + '">' +
					data.locality[i].name + '</li>');
			}
		}
	}
});

//点击歌曲播放
$('#onlineList').on('tap', '.mui-table-view-cell', function() {
		var index = $(this).attr('data-index');
		play(index);
	})
	//点击歌曲播放
$('#localList').on('tap', '.mui-table-view-cell', function() {
		var index = $(this).attr('data-index');
		play(index);
	})
	//播放歌曲
function play(index) {
	localStorage.musicIndex = index;
	audio.src = musics[index].url;
	$('.mus-title').text(musics[index].name);
	$('.mus-author').text(musics[index].author);
	$('#btnStart').attr('class', 'mus-pause');
	audio.play();
	console.log(musics[index].name);
}
//播放下一首
function next() {
	if(musics.length >= localStorage.musicIndex) {
		localStorage.musicIndex = 0;
	} else {
		localStorage.musicIndex += 1;
	}
	play(localStorage.musicIndex);
}
//播放前一首
function prev() {
	if(localStorage.musicIndex <= 0) {
		localStorage.musicIndex = musics.length - 1;
	} else {
		localStorage.musicIndex -= 1;
	}
	console.log(localStorage.musicIndex);
	play(localStorage.musicIndex);
}
