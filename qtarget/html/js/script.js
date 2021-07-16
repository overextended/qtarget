

window.addEventListener('message', function(event) {
	let item = event.data;

	if (item.response == 'openTarget') {
		$(".target-label").html("");
		
		$('.target-wrapper').show();

		$(".target-eye").css("color", "black");
	} else if (item.response == 'closeTarget') {
		$(".target-label").html("");

		$('.target-wrapper').hide();
	} else if (item.response == 'validTarget') {
		$(".target-label").html("");

		$.each(item.data, function (index, item) {
			$(".target-label").append("<div class='target-item' id='target-"+index+"'<li><i class='"+item.icon+" fa-fw fa-pull-left target-icon'></i>"+item.label+"</li></div>");
			$("#target-"+index).hover((e)=> {
				$("#target-"+index).css("color",e.type === "mouseenter"?"rgb(98, 135, 236)":"white")
			})
			
			$("#target-"+index+"").css("padding-top", "7px");

			$("#target-"+index).data('TargetData', item);
		});

		$(".target-eye").css("color", "rgba(255, 255, 255, 0.8)");
	} else if (item.response == 'leftTarget') {
		$(".target-label").html("");

		$(".target-eye").css("color", "black");
	}
});

$(document).on('mousedown', (event) => {
	let element = event.target;
	
	if (element.id.split("-")[0] === 'target') {
		let TargetData = $("#"+element.id).data('TargetData');
		$(".target-label").html("");
		$('.target-wrapper').hide();
		switch (event.which) {
			case 1:
			$.post('http://qtTarget/selectTarget', JSON.stringify(TargetData));
			case 3:
			$.post('http://qtTarget/closeTarget');
			break;
		}
	}
});

$(document).on('keydown', function() {
	switch(event.keyCode) {
		case 27: // ESC
			$(".target-label").html("");
			$('.target-wrapper').hide();
			$.post('http://qtTarget/closeTarget');
			break;
	}
});
