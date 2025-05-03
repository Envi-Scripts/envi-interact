let i = 0;
let typingComplete = false;
let currentMenuID = null;
let keysBusy = false;

$(function() {
  function typeWriter(textParam, callback, element, totalDuration) {
    let i = 0;
    const text = textParam;
    const baseDelay = calculateDynamicDelay(text.length);
    const dynamicDelay = totalDuration ? (totalDuration / text.length) : baseDelay;
  
    function type() {
      if (i < text.length) {
        $(element).append(text.charAt(i));
        i++;
        setTimeout(type, dynamicDelay);
      } else {
        callback();
      }
    }
  
    type();
  }
  
  function calculateDynamicDelay(length) {
    if (length <= 50) {
        return 40;
    } else if (length <= 100) {
        return 30;
    } else {
        return 20;
    }
  };

  function createChoiceMenu(data) {
    if (currentMenuID) {
     // $(`.choice__menu[data-choice-menu="${currentMenuID}"]`).fadeOut("150", function() {
       // $(this).remove();
        displayNewMenu(data);
      //});
    } else {
      displayNewMenu(data);
    }
  }

  function displayNewMenu(data) {
    keysBusy = false;
    i = 0;
    typingComplete = false;
    
    $(`.choice__menu`).remove();
    $(`.bubble__chat--wrapper`).remove();

    $("body").fadeIn("150");

    $("#container").append(`
      <div class="choice__menu ${data.position}" data-choice-menu="${data.menuID}" style="display: none;">
        <div class="choice__container">
          <div class="overlay"></div>
          <div class="choice__title">${data.title}</div>
          <div class="option__wrapper">
            ${data.options.map(option => `
              <div class="option__item" data-key="${option.key}" data-stay-open="${option.stayOpen}" data-close-all=${option.closeAll}>
                <div class="option__key">${option.key}</div>
                <div class="option__content">${option.label}</div>
              </div>
            `).join('')}
          </div>
        </div>
      </div>
    `);

    if (data.speech) {
      $("#container").append(`
        <div class="bubble__chat--wrapper" data-menu-id="${data.menuID}" style="display: none;">
          <div class="bubble__chat--container">
            <div class="overlay"></div>
            <div class="bubble__chat--content" id="text-${data.menuID}"></div>
          </div>
        </div>
      `);
      $(`.bubble__chat--wrapper[data-menu-id="${data.menuID}"]`).fadeIn("150", function() {
        typeWriter(data.speech, () => {
          typingComplete = true;
          $(".option__item").removeClass('disabled');
          $('.slider__wrapper').find(".slider").prop('disabled', false).removeClass('locked');
          $('.slider__wrapper').find(".slider__submit").prop('disabled', false).removeClass('locked');
        }, `#text-${data.menuID}`, data.duration);
      });
    }
     else {
      typingComplete = true;
    };
    $(".choice__menu").fadeIn("150");
    keysBusy = false;
    $(".option__item").on('click', function(e) {
      e.preventDefault();
      if (!typingComplete) return;
      keysBusy = true;
      
      let getStayOpen = $(this).data('stay-open');
      let getCloseAll = $(this).data('close-all');

      if (!getStayOpen) {
        $(".choice__menu").fadeOut("150");
      }

      const key = $(this).data('key');
      const option = data.options.find(opt => opt.key === key);
      const speech = option.speech;
      const reaction = option.reaction;

      $.post('https://envi-interact/selectOption', JSON.stringify({
        menuID: data.menuID,
        key: key,
        selected: option.selected,
        speech: speech,
        closeAll: getCloseAll,
        stayOpen: getStayOpen,
        reaction: reaction
      }));

      closeMenuInternal(currentMenuID);
      currentMenuID = data.menuID;
      setTimeout(() => {
        keysBusy = false;
      }, 1500);

    });

    $(document).off('keydown').on('keydown', function(e) {
      if (!typingComplete || keysBusy) return;
      keysBusy = true;
      setTimeout(() => {
        keysBusy = false;
      }, 1500);
      const pressedKey = String.fromCharCode(e.which);
      const option = data.options.find(opt => opt.key === pressedKey);
      const speech = $(this).data('speech');
      const reaction = $(this).data('reaction');

      if (option) {
        e.preventDefault();
        $(".option__item").removeClass('active');
        const $activeItem = $(`.option__item[data-key="${option.key}"]`).addClass('active');

        let getStayOpen = $activeItem.data('stay-open');
        let getCloseAll = $activeItem.data('close-all');
        if (!getStayOpen) {
          $(".choice__menu").fadeOut("150");
        }

        $.post('https://envi-interact/selectOption', JSON.stringify({
          menuID: data.menuID,
          key: option.key,
          selected: option.selected,
          speech: speech,
          closeAll: getCloseAll,
          stayOpen: getStayOpen,
          reaction: reaction
        }));
      } else if (e.which === 27) {
        e.preventDefault();
        if (data.onESC) {
          $.post('https://envi-interact/escPressed', JSON.stringify({
            menuID: data.menuID
          }));
        }
        closeAllMenus();
      }
    });

    $(document).off('keyup').on('keyup', function(e) {
      const pressedKey = String.fromCharCode(e.which);
      const option = data.options.find(opt => opt.key === pressedKey);

      if (option) {
        const $activeItem = $(`.option__item[data-key="${option.key}"]`);
        $activeItem.removeClass('active');
      }
    });

    data.options.forEach(option => {
      const optionElement = `
        <div class="option__item" data-key="${option.key}" data-stay-open="${option.stayOpen || false}" data-close-all="${option.closeAll || false}">
          <div class="option__key">${option.key}</div>
          <div class="option__label">${option.label}</div>
        </div>
      `;
      $(".choice__menu__options").append(optionElement);
    });

    data.options.forEach(option => {
      if (option.canSee) {
        $.post('https://envi-interact/selectOption', JSON.stringify({
          menuID: data.menuID,
          key: option.key,
          checkcanSee: true
        }), function(response) {
          if (response === 0) {
            $(`.option__item[data-key="${option.key}"]`).addClass('disabled');
          }
        });
      }
    });

  };

  function updateSpeech(data) {
    i = 0;
    typingComplete = false;
    const textElement = `#text-${data.menuID}`;
  
    $(textElement).empty();
    
    typeWriter(data.speech, () => {
      typingComplete = true;
      $(".option__item").removeClass('disabled');
      $('.slider__wrapper').find(".slider").prop('disabled', false).removeClass('locked');
      $('.slider__wrapper').find(".slider__submit").prop('disabled', false).removeClass('locked');
      $.post('https://envi-interact/speechComplete', JSON.stringify({
        menuID: data.menuID
      }));
    }, textElement, data.duration);
  };

  function useSlider(data) {
    let $menu = $(`.choice__menu[data-choice-menu="${data.menuID}"]`);

    if ($menu.length) {
      
      let $sliderWrapper = $menu.find('.slider__wrapper');

      if ($sliderWrapper.length === 0) {
        $menu.append(`
          <div class="slider__wrapper animate__animated animate__fadeInUp animate__faster" style="display: ${data.sliderState === 'disabled' ? 'none' : 'block'}">
            <div class="overlay"></div>
            <div class="slider__container">
              <input type="range" min="${data.min}" max="${data.max}" value="${data.sliderValue}" class="slider" id="myRange">
              <button class="slider__submit">submit</button>
            </div>
            <div class="slider__content">${data.title} <span id="slider-value">${data.sliderValue}</span></div>
          </div>
        `);

        if (data.sliderState === 'locked' || !typingComplete) {
          $('.slider__wrapper').find(".slider").prop('disabled', true).addClass('locked');
          $('.slider__wrapper').find(".slider__submit").prop('disabled', true).addClass('locked');

        } else {
          $('.slider__wrapper').find(".slider").prop('disabled', false).removeClass('locked');
          $('.slider__wrapper').find(".slider__submit").prop('disabled', false).removeClass('locked');
        };

        const updateBubble = () => {
          const value = $('.slider__wrapper').find(".slider").val();
          $('.slider__wrapper').find("#slider-value").text(value);
        };
    
        $('.slider__wrapper').find(".slider").on('input', updateBubble);

        $('.slider__wrapper').find(".slider__submit").on('click', function() {
          let newValue = $('.slider__wrapper').find(".slider").val();
    
          $.post('https://envi-interact/sliderConfirm', JSON.stringify({
            menuID: data.menuID,
            sliderValue: newValue,
            oldValue: data.sliderValue,
            nextState: data.nextState
          })).done(function(res) {
            if (res === 'hideSlider') {
              $('.slider__wrapper')
                .removeClass('animate__fadeInUp animate__faster')
                .addClass('animate__fadeOutDown animate__faster');
              setTimeout(() => {
                $('.slider__wrapper').hide().removeClass('animate__fadeOutDown animate__faster');
              }, 500);
            } else if (res === 'lockSlider') {
              $('.slider__wrapper').find(".slider").prop('disabled', true).addClass('locked');
              $('.slider__wrapper').find(".slider__submit").prop('disabled', true).addClass('locked');

            } else if (res === 'unlockSlider') {
              $('.slider__wrapper').find(".slider").prop('disabled', false).removeClass('locked');
              $('.slider__wrapper').find(".slider__submit").prop('disabled', false).removeClass('locked');
            }
          });
        });
      } else {
        $sliderWrapper.show().addClass('animate__fadeInUp animate__faster');
      }
    }
  };

  function forceUpdateSlider(data) {
    let $menu = $(`.choice__menu[data-choice-menu="${data.menuID}"]`);
    if ($menu.length) {
      let $sliderWrapper = $menu.find(".slider__wrapper");
      $sliderWrapper.find(".slider").val(data.sliderValue);
      $sliderWrapper.find("#slider-value").text(data.sliderValue);
    }
  };

  function createPercentageBar(data) {
    $("body").fadeIn("150");
    let $percentageWrapper = $(`.percentage__wrapper[data-percent-id="${data.percentID}"]`);

    if ($percentageWrapper.length === 0) {  
      let positionClass;
      let dimensionStyle;

      switch (data.position) {
        case 'top':
          positionClass = 'tooltip-bottom';
          dimensionStyle = `width: 0; height: 100%;`;
          break;
        case 'bottom':
          positionClass = 'tooltip-top';
          dimensionStyle = `width: 0; height: 100%;`;
          break;
        case 'left':
          positionClass = 'tooltip-top-left';
          dimensionStyle = `width: 100%; height: 0;`;
          break;
        case 'right':
          positionClass = 'tooltip-top-right';
          dimensionStyle = `width: 100%; height: 0;`;
          break;
        default:
          positionClass = 'tooltip-top-left';
          dimensionStyle = `width: 100%; height: 0;`;
          break;
      }
  
      $("#container").append(`
        <div class="percentage__wrapper ${data.position}" data-percent-id="${data.percentID}" style="display: none">
          <div class="percentage__container ${positionClass} tooltip-${data.tooltip}" data-tooltip="${data.title}">
            <div class="percentage__inner--container" style="${dimensionStyle}"></div>
          </div>
        </div>
      `);

      $percentageWrapper = $(`.percentage__wrapper[data-percent-id="${data.percentID}"]`);
  
      $percentageWrapper.fadeIn("150", function() {
        const dimension = (data.position === 'left' || data.position === 'right') ? 'height' : 'width';
        const $innerContainer = $percentageWrapper.find('.percentage__inner--container');
        updateColor($innerContainer, data.percentage, dimension, data.colors);
      });

      $(document).on('keydown.percentageBar', function(e) {
        if (e.which === 27) {
          e.preventDefault();
          closeAllMenus();
        }
      });
    } else {
      $percentageWrapper.show();
      const dimension = (data.position === 'left' || data.position === 'right') ? 'height' : 'width';
      const $innerContainer = $percentageWrapper.find('.percentage__inner--container');
      updateColor($innerContainer, data.percentage, dimension, data.colors);
      $percentageWrapper.find('.percentage__container')
        .attr('data-tooltip', `${data.title}`)
        .removeClass('tooltip-none tooltip-hover tooltip-always')
        .addClass(`tooltip-${data.tooltip}`);
    }
  };

  function updateColor($element, percentage, dimension, colors) {
    let color;
    if (percentage <= 24) {
        color = colors.c1 || 'red';
    } else if (percentage <= 75) {
        color = colors.c2 || '#FFC000';
    } else {
        color = colors.c3 || 'green';
    }

    $element.css('background-color', color);
    $element.css(dimension, `${percentage}%`);
  };

  function closeMenu(data) {
    let $menu = $(`.choice__menu[data-choice-menu="${data.menuID}"]`);
    let $percentage = $(`.percentage__wrapper[data-percent-id="${data.percentID}"]`);

    if ($menu.length) {
        $menu.fadeOut("150");
        $(".bubble__chat--wrapper").fadeOut("150", function() {
            $(this).find('#text').empty();
        });
    }

    if ($percentage.length) {
      $percentage.fadeOut("150");
    }

    $.post('https://envi-interact/close', JSON.stringify({ menuID: data.menuID }));
  };

  function closeMenuInternal(data) {
    if (!data || !data.menuID) {
      return;
    }
    let $menu = $(`.choice__menu[data-choice-menu="${data.menuID}"]`);
    let $percentage = $(`.percentage__wrapper[data-percent-id="${data.percentID}"]`);
        $menu.fadeOut("150");
        $(".bubble__chat--wrapper").fadeOut("150", function() {
            $(this).find('#text').empty();
        });

    if ($percentage.length) {
      $percentage.fadeOut("150");
    }
    
  };


  function closeAllMenus() {
    $(".choice__menu").fadeOut("150");
    $(".percentage__wrapper").fadeOut("150");
    $(".bubble__chat--wrapper").fadeOut("150", function() {
        $(this).find('#text').empty();
    });

    $.post('https://envi-interact/closeAll', JSON.stringify({}));
  }

  $(document).on('keydown', function(e) {
      if (e.which === 27) {
        closeAllMenus();
      }
  });

  window.addEventListener('message', function(e) {
    let data = e?.data;
  
    switch (data.action) {
      case "openChoiceMenu":
        createChoiceMenu(data);
        break; // Added break here
      case "openPedMenu":
        createChoiceMenu(data);
        break;
      case "updateSpeech":
        updateSpeech(data);
        break;  
      case "useSlider":
        useSlider(data);
        break;
      case "forceUpdateSlider":
        forceUpdateSlider(data);
        break;
      case "closeMenu":
        closeMenu(data);
        break;
      case "percentageBar":
        createPercentageBar(data);
        break;
      case "updatePercentageBar":
        updatePercentageBar(data);
        break;    
      default:
        // console.log(data);
        break;
    }
  });
})