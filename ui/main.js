$(document).ready(function() {
    $('#controls').hide(); 
    $('.mouse-control').hide(); 
    $('#pedIcon').hide(); 
    let isMouseControlActive = false;
    let isMouseDown = false;

    window.addEventListener('message', function(event) {
        var data = event.data;

        switch(data.action) {
            case "showUI":
                $('#controls').show();
                break;
            case "hideUI":
                $('#controls').hide();
                $('#pedIcon').hide(); 
                break;
            case "presseffect":
                $('#' + data.key).addClass('presseffect');
                setTimeout(function() {
                    $('#' + data.key).removeClass('presseffect');
                }, 200);
                break;
            case "showMouseControl":
                isMouseControlActive = true;
                $('.mouse-control').show(); 
                break;
            case "hideMouseControl":
                isMouseControlActive = false;
                $('.mouse-control').hide(); 
                isMouseDown = false; 
                break;
            case "updatePedIconPosition":
                if ($("#pedIcon").length === 0) {
                    $("#controls").append(`
                        <div id="pedIcon" style="position: absolute; left: ${data.x * 100}%; top: ${data.y * 100}%; transform: translate(-50%, -50%);">
                            <iconify-icon icon="dashicons:leftright"></iconify-icon>    
                            <iconify-icon icon="icon-park-outline:turn-on"></iconify-icon>
                        </div>
                    `);
                } else {
                    $("#pedIcon").css({
                        left: `${data.x * 100}%`,
                        top: `${data.y * 100}%`
                    });
                }
                $('#pedIcon').show(); 
                break;
            case "deleteIcon":
                $('#pedIcon').hide();
            break;
        }
    });

    $(document).keydown(function(e) {
        if (e.key === "Alt") {
            isMouseControlActive = !isMouseControlActive;
            if (isMouseControlActive) {
                $.post('https://fx-animpos/altPressed', JSON.stringify({active: true}));
                $('.mouse-control').show();
                $('#pedIcon').show();
            } else {
                $.post('https://fx-animpos/altPressed', JSON.stringify({active: false}));
                $('.mouse-control').hide();
                $('#pedIcon').hide();
            }
        }
    });

    $(document).mousedown(function(event) {
        if (isMouseControlActive && event.which === 1) { 
            isMouseDown = true;
        }
    });

    $(document).mouseup(function(event) {
        if (event.which === 1) { 
            isMouseDown = false;
        }
    });

    $(document).mousemove(function(event) {
        if (isMouseControlActive && isMouseDown) {
            let movementX = event.originalEvent.movementX;

            $.post('https://fx-animpos/mouseMove', JSON.stringify({
                movementX: movementX
            }));
        }
    });
});
