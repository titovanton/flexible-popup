root = exports ? this

jQuery ($) ->

    log = (text) ->
        try
            console.log text
        catch e
            ;

    root.popupSettings =
        blackoutClass: 'popup-blackout'
        closeClass: 'popup-close'
        closeExtraClass: 'sprite-close'
        contentClass: 'popup-content'
        popupExtraClass: false


        prevPopup: false
        url: false

        add: (cntnt, stngs) ->
            $popup = $ ".popup-window"

            # stack
            if $popup.size()
                stngs.prevPopup = $popup
                $popup.removeClass 'active'
            else
                $('<div>')
                    .addClass stngs.blackoutClass
                    .appendTo 'body'

            # generate
            $popup = $('<aside>')
                .addClass 'popup-window'
                .addClass stngs.popupExtraClass
                .append $('<i>').addClass(stngs.closeClass).addClass stngs.closeExtraClass
                .appendTo 'body'
            $content = $('<section>')
                .addClass stngs.contentClass
                .append $ cntnt
                .appendTo $popup

            # size and position
            width = parseInt $content.outerWidth true
            width += parseInt $popup.css 'padding-left'
            width += parseInt $popup.css 'padding-right'
            minWidth = parseInt $popup.css 'min-width'
            width = width > minWidth and width or minWidth

            $popup
                .css
                    width: width
                    'margin-left': -width/2

            height = parseInt $content.outerHeight true
            height += parseInt $popup.css 'padding-top'
            height += parseInt $popup.css 'padding-bottom'
            minHeight = parseInt $popup.css 'min-height'
            height = height > minHeight and height or minHeight

            $popup
                .data 'popupSettings', stngs
                .css
                    'margin-top': -height/2
                    height: height
                .addClass 'active'

        del: (stngs) ->
            $popup = $(".popup-window.active")

            if stngs.prevPopup
                stngs.prevPopup.addClass 'active'
            else
                $(".#{stngs.blackoutClass}").remove()

            $popup.remove()

    popupHandlers =

        init: (jsInit, self=false) ->
            settings = {}

            # HTML attr init
            if self
                except = ['add', 'del',]
                for k of popupSettings
                    if $.inArray(k, except) is -1
                        attr = "data-#{k}"
                        if typeof($(self).attr attr) != 'undefined'
                            settings[k] = $(self).attr attr

            # deep clone
            $.extend true, {}, popupSettings, jsInit, settings

        close: () ->
            stngs = $(@).parents('.popup-window').data 'popupSettings'
            stngs.del stngs

        ajax: (e, jsInit) ->
            settings = popupHandlers.init jsInit, @

            if settings.url
                $.ajax
                    url: settings.url
                    async: false
                    success: (response) ->
                        popupSettings.add response, settings
                        $(document).trigger 'popupAjaxSuccess'
            else
                log 'ERROR: specify url'

        serverError: (e, jsInit) ->
            settings = popupHandlers.init jsInit

            if settings.popupExtraClass
                settings.popupExtraClass += ' popup-error'
            else
                settings.popupExtraClass = 'popup-error'

            msg = '<h3>Ooops!</h3>
                    <p>На сервере произошла ошибка.</p>
                    <p>Простите, мы скоро исправимся!</p>
                    <footer>
                        <button class="btn popup-close">продолжить</button>
                    </footer>'
            popupSettings.add msg, settings

        formError: (e, jsInit) ->
            settings = popupHandlers.init jsInit

            if settings.popupExtraClass
                settings.popupExtraClass += ' popup-error'
            else
                settings.popupExtraClass = 'popup-error'

            msg = '<h3>Ooops!</h3>
                    <p>Вы допустили ошибку при заполнении формы.</p>
                    <p>Пропущенные поля мы выделили для Вас красным цветом.</p>
                    <footer>
                        <button class="btn popup-close">продолжить</button>
                    </footer>'
            popupSettings.add msg, settings

        popup: (e, msg='<p>empty</p>', jsInit) ->
            settings = popupHandlers.init jsInit
            popupSettings.add msg, settings

    $(document).on 'click', '.popup-launcher', popupHandlers.ajax
    $(document).on 'click', '.popup-close', popupHandlers.close
    $(document).on 'formError', popupHandlers.formError
    $(document).on 'popup', popupHandlers.popup
    $(document).on 'serverError', popupHandlers.serverError
