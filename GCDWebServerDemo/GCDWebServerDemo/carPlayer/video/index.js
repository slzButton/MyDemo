

Mock.mock('http://phone.cn', {
  "online": [
    {
    "name": "我也不知道是啥",
    "url": "http://192.168.4.244:8080/1.mp4"
    }
  ]
});
var musics = [];
var index = 0;
$.ajax({
	url: 'http://phone.cn',
	dataType: 'json',
	success: function(data) {
		if(data.online.length > 0) {
			musics = data.online;
			for(var i = 0, len = data.online.length; i < len; i++) {
				$('#videoList').append('<li class="mui-table-view-cell" data-index="' +
					i + '"data-src = "' + data.online[i].url + '"data-name="' + data.online[i].name + '">' +
					data.online[i].name + '</li>');
			}
		}
	}
});


$('#videoList').on('tap', '.mui-table-view-cell', function() {
	var url = $(this).attr('data-src');
	myPlayer.src(url); //重置video的src
	myPlayer.load(url); //使video重新加载
                   myPlayer.play();
                   console.log(url);
})
