window.addEventListener('message', function (event) {
  let item = event.data;

  if (item.response == 'openTarget') {
    $('.target-label').html('');
    $('.target-wrapper').show();
    $('.target-eye').css('color', 'black');
  } else if (item.response == 'closeTarget') {
    $('.target-label').html('');
    $('.target-wrapper').hide();
  } else if (item.response == 'validTarget') {
    $('.target-label').html('');

    for (let [index, itemData] of Object.entries(item.data)) {
      if (itemData !== null) {
        index = Number(index) + 1;

        $('.target-label').append(
          `<div class='target-item' id='${index}'><i class='${itemData.icon} fa-fw fa-pull-left target-icon'></i>${itemData.label}</div>`
        );

        $(`#${index}`).css('padding-top', '0.75vh');
      }
    }

    $('.target-eye').css('color', 'rgba(255, 255, 255, 0.8)');
  } else if (item.response == 'leftTarget') {
    $('.target-label').html('');
    $('.target-eye').css('color', 'black');
  }
});

$(document).on('mousedown', (event) => {
  switch (event.which) {
    case 1: {
      const id = event.target.id;

      if (id) $.post(`https://${GetParentResourceName()}/selectTarget`, JSON.stringify(id));

      $('.target-label').html('');
      $('.target-wrapper').hide();
      break;
    }
    case 3: {
      $.post(`https://${GetParentResourceName()}/leftTarget`);

      $('.target-label').html('');
      $('.target-eye').css('color', 'black');
      break;
    }
  }
});

$(document).on('keydown', (event) => {
  switch (event.key) {
    case 'Escape':
    case 'Backspace': {
      $.post(`https://${GetParentResourceName()}/closeTarget`);

      $('.target-label').html('');
      $('.target-wrapper').hide();
      $('.target-eye').css('color', 'black');
    }
  }
});

$(document).on('mouseover', (event) => {
  const element = event.target;

  if (element.id) $(`#${element.id}`).css('color', 'rgb(98, 135, 236)');
});

$(document).on('mouseout', (event) => {
  const element = event.target;

  if (element.id) $(`#${element.id}`).css('color', 'white');
});