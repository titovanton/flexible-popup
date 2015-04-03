root = exports ? this

jQuery ($) ->

    log = (text) ->
        try
            console.log text
        catch e
            ;

    root.popupSettings =
        blackoutId: 'popup-blackout'
        closeClass: 'popup-close'
        closeSpriteClass: 'sprite-close'
        contentId: 'popup-content'
        popupId: 'popup-window'

        popupPudding: 25
        popupMinWidth: 400
        popupMinHeight: 200

        popupStack: []

        make: (c) ->
            p = popupSettings
            $popup = $ "<aside id=#{p.popupId}>"
                .append $("<i class=#{p.closeClass}>").addClass p.closeSpriteClass
                .append $("<section id=#{p.contentId}>").html c

        add: (c) ->
            p = popupSettings
            $popup = $ "#{p.popupId}"

            if $popup.size()
                $popup.remove()
                p.popupStack.push $popup
            else
                $("<div id=#{p.blackoutId}>")
                    .css
                        visibility: 'hidden'
                    .appendTo 'body'

            p.make(c)
                .css
                    visibility: 'hidden'
                .appendTo 'body'

        del: () ->
            p = popupSettings
            $("#{p.popupId}").remove()

            if p.popupStack.length
                p.popupStack.pop().appendTo 'body'
            else
                $("#{p.blackoutId}").remove()

        show: () ->
            $('#popup-blackout').css
                visibility: 'visible'
            $('#popup-window').css
                visibility: 'visible'

    popupHandlers =
        popupBusy: false

        close: () ->
            popupSettings.del()

        position: () ->
            d = popupSettings.popupPudding * 2
            width = parseInt($('#popup-content').outerWidth(true)) + d
            height = parseInt($('#popup-content').outerHeight(true)) + d
            minWidth = popupSettings.popupMinWidth
            minHeight = popupSettings.popupMinHeight
            width = width > minWidth and width or minWidth
            height = height > minHeight and height or minHeight

            $('#popup-window').css
                'margin-left': -width/2
                'margin-top': -height/2
                height: height
                width: width

        ajax: () ->
            url = $(@).attr('data-url')
            if not popupHandlers.popupBusy and url
                popupHandlers.popupBusy = true

                $.get url, (response) ->
                    popupSettings.add response
                    popupHandlers.position()
                    popupHandlers.show()
                    popupHandlers.popupBusy = false

        serverError: () ->
            msg = '<article id="popup-error">
                    <h3>Ooops!</h3>
                    <p>На сервере произошла ошибка.</p>
                    <p>Простите, мы скоро исправимся!</p>
                    <footer>
                        <button class="btn popup-close">продолжить</button>
                    </footer>
                </article>'
            popupSettings.add msg
            popupHandlers.position()
            popupHandlers.show()

        formError: () ->
            msg = '<article id="popup-error">
                    <h3>Ooops!</h3>
                    <p>Вы допустили ошибку при заполнении формы.</p>
                    <p>Пропущенные поля мы выделили для Вас красным цветом.</p>
                    <footer>
                        <button class="btn popup-close">продолжить</button>
                    </footer>
                </article>'
            popupSettings.add msg
            popupHandlers.position()
            popupHandlers.show()

        popup: (e, msg='<p>empty</p>') ->
            popupSettings.add msg
            popupHandlers.position()
            popupHandlers.show()

    $(document).on 'click', '.popup-launcher', popupHandlers.ajax
    $(document).on 'click', '.popup-close', popupHandlers.close
    $(document).on 'formError', popupHandlers.formError
    $(document).on 'popup', popupHandlers.popup
    $(document).on 'serverError', popupHandlers.serverError
    # $(document).ajaxError popupHandlers.serverError
