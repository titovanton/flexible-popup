root = exports ? this

jQuery ($) ->

    log = (text) ->
        try
            console.log text
        catch e
            ;


    # Stack Item class, contains popup src
    class FlexiblePopupItem
        popupClass: 'popup-window'
        closeClass: 'popup-close'
        contentClass: 'popup-content'

        popupExtraClass: false
        closeExtraClass: 'sprite-close'
        content = false
        url: false

        constructor: (options) ->
            {@popupExtraClass, @closeExtraClass, @content, @url} = options

            if not flexiblePopupStack?
                log 'FlexiblePopup: [ERROR] You have to instance FlexiblePopupStack first'

            if @url

                if flexiblePopupStack.contentCache[@url]?
                    @content = flexiblePopupStack.contentCache[@url]
                else
                    $.ajax
                        url: @url
                        async: false
                        success: ((response) -> @content = response).bind @

                    flexiblePopupStack.contentCache[@url] = @content

        generate: () ->
            $popup = $('<aside>')
                .addClass @popupClass
                .addClass @popupExtraClass

            $('<i>')
                .addClass @closeClass
                .addClass @closeExtraClass
                .appendTo $popup

            $content = $('<section>')
                .addClass @contentClass
                .append $ @content
                .appendTo $popup

            $popup

        drawPopup: ($popup) ->
            $popup
                .css
                    visibility: 'hidden'
                .appendTo 'body'

            $content = $popup.find ".#{@contentClass}"

            width = parseInt $content.outerWidth true
            width += parseInt $popup.css 'padding-left'
            width += parseInt $popup.css 'padding-right'
            minWidth = parseInt $popup.css 'min-width'

            if width < minWidth
                width = minWidth
                $popup.css width: width

            $popup.css 'margin-left': -width/2

            height = parseInt $content.outerHeight true
            height += parseInt $popup.css 'padding-top'
            height += parseInt $popup.css 'padding-bottom'
            minHeight = parseInt $popup.css 'min-height'

            if height < minHeight
                height = minHeight
                $popup.css height: height

            $popup.css
                'margin-top': -height/2
                visibility: 'visible'

            $popup.trigger 'flexiblePopupShown'


    # Stack of Popups
    class FlexiblePopupStack
        blackoutClass: 'popup-blackout'
        contentCache: {}
        stack: []

        push: (item) ->

            if @stack.length
                $ ".#{FlexiblePopupItem::popupClass}"
                    .remove()

            @stack.push item

            $popup = item.generate()
            $popup = item.drawPopup $popup

        pop: () ->
            @stack.pop()

            $ ".#{FlexiblePopupItem::popupClass}"
                .remove()

            if not @stack.length
                $ ".#{@blackoutClass}"
                    .remove()
            else
                [..., last] = @stack
                $popup = last.generate()
                $popup = last.drawPopup $popup

        # redraw: () ->
        #     [..., last] = @stack

        #     if last?
        #         $popup = $ ".#{FlexiblePopupItem::popupClass}"
        #             # .remove()

        #         $popup.css
        #             width: 'auto'
        #             height: 'auto'

        #         # @stack.drawPopup $popup


    # Handlers
    instanceStack = () ->

        if not flexiblePopupStack?
            root.flexiblePopupStack = new FlexiblePopupStack

        # blackout first
        if not flexiblePopupStack.stack.length
            $('<div>')
                .addClass flexiblePopupStack.blackoutClass
                .appendTo 'body'

        flexiblePopupStack


    jsInit = (e, init) ->
        stack = instanceStack()
        item = new FlexiblePopupItem init
        stack.push item


    htmlInit = () ->
        stack = instanceStack()
        init = {}
        $this = $ @

        filter = ['popupExtraClass', 'closeExtraClass', 'content', 'url',]

        for k in filter
            attr = "data-#{k}"

            if $this.attr(attr)?
                init[k] = $this.attr attr

        item = new FlexiblePopupItem init
        stack.push item


    close = () ->
        stack = instanceStack()
        stack.pop()


    # redrawPopup = () ->
    #     stack = instanceStack()
    #     stack.redraw()


    serverError = (e, init) ->

        if init['popupExtraClass']?
            init['popupExtraClass'] += ' popup-error'
        else
            init['popupExtraClass'] = 'popup-error'

        init['content'] = '<h3>Ooops!</h3>
                            <p>На сервере произошла ошибка.</p>
                            <p>Простите, мы скоро исправимся!</p>
                            <footer>
                                <button class="btn popup-close">продолжить</button>
                            </footer>'
        jsInit e, init


    formError = (e, init) ->

        if init['popupExtraClass']?
            init['popupExtraClass'] += ' popup-error'
        else
            init['popupExtraClass'] = 'popup-error'

        init['content'] = '<h3>Ooops!</h3>
                            <p>Вы допустили ошибку при при вводе данных.</p>
                            <p>Пропущенные поля мы выделили для Вас красным цветом.</p>
                            <footer>
                                <button class="btn popup-close">исправить</button>
                            </footer>'
        jsInit e, init


    $(document).on 'click', '.popup-launcher', htmlInit
    $(document).on 'click', '.popup-close', close
    $(document).on 'formError', formError
    $(document).on 'popup', jsInit
    $(document).on 'serverError', serverError
    # $(document).on 'redrawPopup', redrawPopup
