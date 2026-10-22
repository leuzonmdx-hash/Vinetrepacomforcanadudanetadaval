-- ============================================
-- 01. CONFIGURAÇÕES E IMPORTS ANDROID
-- ============================================
gg.setVisible(false)
local imports = {
    "android.view.*",
    "android.widget.*",
    "android.graphics.*",
    "android.graphics.drawable.*",
    "android.view.MotionEvent",
    "android.view.WindowManager",
    "android.animation.ObjectAnimator",
    "android.animation.ValueAnimator",
    "android.view.animation.LinearInterpolator",
    "android.view.animation.AccelerateDecelerateInterpolator",
    "android.graphics.Paint",
    "android.graphics.Canvas",
    "android.graphics.Typeface",
    "android.text.TextUtils$TruncateAt",
    "android.text.Editable",
    "android.text.TextWatcher",
    "android.view.KeyEvent",
    "android.view.inputmethod.InputMethodManager",
    "android.app.ActivityManager",
    "android.view.Choreographer"
}

for _, lib in ipairs(imports) do import(lib) end

local Build = luajava.bindClass("android.os.Build")
local LayoutParams = luajava.bindClass("android.view.WindowManager$LayoutParams")
local BitmapFactory = luajava.bindClass("android.graphics.BitmapFactory")
local Bitmap = luajava.bindClass("android.graphics.Bitmap")
local Canvas = luajava.bindClass("android.graphics.Canvas")
local Paint = luajava.bindClass("android.graphics.Paint")
local PorterDuff = luajava.bindClass("android.graphics.PorterDuff")
local PorterDuffXfermode = luajava.bindClass("android.graphics.PorterDuffXfermode")
local Rect = luajava.bindClass("android.graphics.Rect")
local Typeface = luajava.bindClass("android.graphics.Typeface")
local ColorStateList = luajava.bindClass("android.content.res.ColorStateList")
local GradientDrawable = luajava.bindClass("android.graphics.drawable.GradientDrawable")
local StateListDrawable = luajava.bindClass("android.graphics.drawable.StateListDrawable")
local FrameLayoutParams = luajava.bindClass("android.widget.FrameLayout$LayoutParams")
local LayerDrawable = luajava.bindClass("android.graphics.drawable.LayerDrawable")
local LinearLayoutParams = luajava.bindClass("android.widget.LinearLayout$LayoutParams")
local TruncateAt = luajava.bindClass("android.text.TextUtils$TruncateAt")
local Html = luajava.bindClass("android.text.Html")
local KeyEvent = luajava.bindClass("android.view.KeyEvent")
local InputMethodManager = luajava.bindClass("android.view.inputmethod.InputMethodManager")
local AccelerateDecelerateInterpolator = luajava.bindClass("android.view.animation.AccelerateDecelerateInterpolator")
local FrameLayout = luajava.bindClass("android.widget.FrameLayout")

local context = activity
local window = context.getSystemService("window")
local IMAGE_URL = "https://iili.io/BZYoLBt.png"
local FONT_URL = "https://github.com/FortAwesome/Font-Awesome/raw/master/webfonts/fa-solid-900.ttf"
 
local FontAwesome = nil 
local is_minimized = false 
local menu_active = true
local switchStates = {}
local originalValues = {}
local assets_loaded = { image = false, font = false }
local assets_error = { image = false, font = false }
local is_retrying = false
local fps_view = nil
local fps_label = nil
local show_fps_enabled = false
local Point = nil
local Point_posX_val, Point_posY_val = 100, 200
local Point_sizePx = "60dp" 

-- ============================================
-- VARIÁVEIS DA MIRA CRUZ CROSSHAIR 
-- ============================================
local miraView = nil
local miraContainer = nil
local miraParams = nil
local MIRA_COR = "#FF0000"
local OFFSET_X = -58
local OFFSET_Y = -2
local mira_ativa = false



pcall(function()
    local HotPoint = luajava.bindClass("android.ext.HotPoint")
    local FloatPanel = luajava.bindClass("android.ext.FloatPanel")
    Point = HotPoint.instance
    
    local f_posX = FloatPanel.getDeclaredField("j"); f_posX.setAccessible(true)
    local f_posY = FloatPanel.getDeclaredField("k"); f_posY.setAccessible(true)
    Point_posX_val = f_posX.getInt(Point)
    Point_posY_val = f_posY.getInt(Point)
    
    local getSizeMethod = HotPoint.getDeclaredMethod("getSizePx", nil)
    getSizeMethod.setAccessible(true)
    Point_sizePx = tostring(getSizeMethod.invoke(Point, nil)).."px"
end)

-- ============================================
-- 02. ÍCONES E RECURSOS VISUAIS
-- ============================================
local FontIcon = {
    menu = {
        ['power-off'] = 0xF011,
        ['fa-user']      = 0xF007, 
        ['BookMark'] = 0xF02E, 
        ['search']    = 0xF002, 
        ['loading']   = 0xF1CE,
        ['close']     = 0xF00D,
        ['circle-notch'] = 0xf1ce,
        ['eye-icon'] = 0xF06E,
        ['fa-cog'] = 0xF4FE,
        ['crosshair'] = 0xF05B,
        ['fa-map'] = 0xF279,
        ['fa-gamepad'] = 0xF11B,
        ['fa-code'] = 0xF121,
    },
    switches = {
        ['sw_fps']        = 0xF21D,
        ['sw_Free_Shop']  = 0xF07A,   
        ['sw_protection'] = 0xE06C,
        ['sw_teste']      = 0xF07A,
        ['sw_mira']       = 0xF05B,
    },
    seekbars = {
        ['sb_Game_Speed'] = 0xF70C,
    }
}

local function toJavaInt(hex)
    local status, result = pcall(function()
        local num = tonumber(hex, 16)
        if num > 2147483647 then num = num - 4294967296 end
        return math.floor(num)
    end)
    if not status then return 0 end
    return result
end

function dp2px(dp)
    return math.floor(dp * context.getResources().getDisplayMetrics().density + 0.5)
end

local function getIcon(code) return utf8.char(code) end

local function applyIcons()
    pcall(function()
        if not FontAwesome then return end
        
        local function setIcon(view, code, text)
            if view and code then
                view.setTypeface(FontAwesome)
                local icon = utf8.char(code)
                if text then
                    view.setText(icon .. "  " .. text)
                else
                    view.setText(icon)
                end
            end
        end
        
        setIcon(btn_settings_nut, FontIcon.menu['fa-cog'])
        setIcon(btn_exit, FontIcon.menu['close'], "CLOSE")        
        setIcon(tab_player, FontIcon.menu['fa-user'], "PLAYER")
        setIcon(tab_visual, FontIcon.menu['eye-icon'], "ANTENA")
        setIcon(tab_mapas, FontIcon.menu['fa-map'], "BYPASS")
        setIcon(tab_cheats, FontIcon.menu['fa-gamepad'], "CHEATS")
        setIcon(tab_regedit, FontIcon.menu['fa-code'], "REGEDIT")
        
        if menu_title then
            menu_title.setTypeface(FontAwesome)
            local titleIcon = utf8.char(FontIcon.menu['BookMark'])
            local currentText = tostring(menu_title.getText()):gsub(utf8.char(FontIcon.menu['BookMark']), ""):gsub("^%s+", "")
            menu_title.setText(titleIcon .. "  " .. currentText)
        end
    end)
end

local function getCircularBitmap(bitmap)
    local status, result = pcall(function()
        if not bitmap then return nil end
        local width, height = bitmap.getWidth(), bitmap.getHeight()
        local size = math.min(width, height)
        local output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        local canvas = luajava.new(Canvas, output)
        local paint = luajava.new(Paint)
        local rect = luajava.new(Rect, (width - size) / 2, (height - size) / 2, (width + size) / 2, (height + size) / 2)
        local rectDestination = luajava.new(Rect, 0, 0, size, size)        
        paint.setAntiAlias(true)
        canvas.drawCircle(size / 2, size / 2, size / 2, paint)      
        paint.setXfermode(luajava.new(PorterDuffXfermode, PorterDuff.Mode.SRC_IN))
        canvas.drawBitmap(bitmap, rect, rectDestination, paint)       
        return output
    end)
    return status and result or bitmap
end

-- ============================================
-- 03. DOWNLOAD E CARREGAMENTO DE RECURSOS
-- ============================================
local function load_assets_direct()
    assets_error.image = false
    assets_error.font = false
    thread(function()
        local URL = luajava.bindClass("java.net.URL")
        local Array = luajava.bindClass("java.lang.reflect.Array")
        local Byte = luajava.bindClass("java.lang.Byte")
        
        local function processDownload(urlStr, type, id)
            local success = false
            pcall(function()
                local conn = URL(urlStr).openConnection()
                conn.setConnectTimeout(10000)
                conn.setRequestProperty("User-Agent", "Mozilla/5.0")
                
                if conn.getResponseCode() == 200 then
                    local input = conn.getInputStream()
                    if type == "font" then
                        local tempPath = context.getFilesDir().getAbsolutePath() .. "/fa-solid-900.ttf"
                        local output = luajava.new(luajava.bindClass("java.io.FileOutputStream"), tempPath)
                        local buffer = Array.newInstance(Byte.TYPE, 8192)
                        local bytesRead = input.read(buffer)
                        while bytesRead ~= -1 do output.write(buffer, 0, bytesRead) bytesRead = input.read(buffer) end
                        output.close() input.close()
                        FontAwesome = luajava.bindClass("android.graphics.Typeface").createFromFile(tempPath)
                        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { 
                            run = function() assets_loaded.font = true; applyIcons(); updateTabContent("PLAYER") end 
                        }))
                    elseif type == "image" then
                        local bitmap = BitmapFactory.decodeStream(input)
                        if bitmap then
                            local circular = getCircularBitmap(bitmap)
                            _G["cached_banner"] = circular
                            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { 
                                run = function() 
                                    if img_banner then 
                                        img_banner.setImageBitmap(circular)
                                        img_banner.setBackground(nil)
                                    end
                                    assets_loaded.image = true 
                                end 
                            }))
                        end
                    end
                    success = true
                end
            end)
            return success
        end

        processDownload(IMAGE_URL, "image", "main_banner")
        processDownload(FONT_URL, "font")
    end)
end

local function loadLogo(ImageView)
    thread(function()
        local status, bitmap = pcall(function() 
            local conn = luajava.bindClass("java.net.URL")(IMAGE_URL).openConnection()
            conn.setConnectTimeout(10000)
            conn.setRequestProperty("User-Agent", "Mozilla/5.0")
            return BitmapFactory.decodeStream(conn.getInputStream())
        end)
        
        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
            run = function()
                if status and bitmap then
                    local circular = getCircularBitmap(bitmap)
                    if ImageView then
                        ImageView.setImageBitmap(circular)
                        ImageView.setBackground(nil)
                    end
                    if img_banner then img_banner.setImageBitmap(circular) end
                    assets_loaded.image = true 
                else
                    assets_error.image = true 
                end
            end
        }))
    end)
end

-- ============================================
-- 04. CONTADOR DE FPS
-- ============================================
local function createFpsOverlay()
    if fps_view then return end
    
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            pcall(function()
                fps_view = luajava.new(LinearLayout, context)
                fps_view.setOrientation(0)
                fps_view.setGravity(17)
                fps_view.setPadding(dp2px(12), dp2px(4), dp2px(12), dp2px(4))
                
                local gd = luajava.new(GradientDrawable)
                gd.setColor(toJavaInt("D91C1C1E")) 
                gd.setCornerRadius(dp2px(20)) 
                gd.setStroke(dp2px(0.5), toJavaInt("4DFFFFFF")) 
                fps_view.setBackground(gd)
                
                fps_label = luajava.new(TextView, context)
                fps_label.setTextColor(toJavaInt("FF34C759")) 
                fps_label.setTextSize(13) 
                fps_label.setTypeface(Typeface.create("sans-serif-medium", Typeface.NORMAL))
                fps_label.setText("FPS: --")
                fps_view.addView(fps_label)
                
                local f_lp = luajava.new(LayoutParams)
                f_lp.type = (Build.VERSION.SDK_INT >= 26) and 2038 or 2002
                f_lp.format = -3
                f_lp.gravity = 51 
                f_lp.flags = 8 | 16 | 32 
                f_lp.width = -2
                f_lp.height = -2
                f_lp.x = dp2px(25) 
                f_lp.y = dp2px(25) 
                
                window.addView(fps_view, f_lp)
                fps_view.setVisibility(8)
            end)
        end
    }))
end

local function toggleFpsCounter(enable)
    show_fps_enabled = enable
    if not fps_view then createFpsOverlay() end
    
    local System = luajava.bindClass("java.lang.System")
    local Choreographer = luajava.bindClass("android.view.Choreographer")
    
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            if fps_view then 
                pcall(function()
                    if enable then
                        fps_view.setVisibility(0)
                        fps_view.setAlpha(0)
                        fps_view.setScaleX(0.8)
                        fps_view.setScaleY(0.8)
                        fps_view.animate()
                            .alpha(1)
                            .scaleX(1)
                            .scaleY(1)
                            .setDuration(400)
                            .setInterpolator(luajava.new(AccelerateDecelerateInterpolator))
                            .start()
                    else
                        fps_view.animate()
                            .alpha(0)
                            .scaleX(0.8)
                            .scaleY(0.8)
                            .setDuration(300)
                            .withEndAction(luajava.createProxy("java.lang.Runnable", {
                                run = function() fps_view.setVisibility(8) end
                            })).start()
                    end
                end)
            end
        end
    }))

    if enable then
        thread(function()
            local lastMillis = System.currentTimeMillis()
            local frames = 0
            local frameCallback
            
            frameCallback = luajava.createProxy("android.view.Choreographer$FrameCallback", {
                doFrame = function(frameTimeNanos)
                    if show_fps_enabled and (menu_active ~= false) then
                        frames = frames + 1
                        Choreographer.getInstance().postFrameCallback(frameCallback)
                    end
                end
            })

            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                run = function() Choreographer.getInstance().postFrameCallback(frameCallback) end
            }))

            while show_fps_enabled and (menu_active ~= false) do 
                local currentMillis = System.currentTimeMillis()
                local diff = currentMillis - lastMillis
                
                if diff >= 500 then 
                    local fps = math.floor((frames * 1000) / diff)
                    if fps > 121 then fps = 60 end 

                    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                        run = function()
                            pcall(function()
                                if fps_label and fps_view and fps_view.getParent() ~= nil then 
                                    fps_label.setText(string.format("FPS: %d", fps))
                                    
                                    if fps >= 55 then
                                        fps_label.setTextColor(toJavaInt("FF34C759")) 
                                    elseif fps >= 35 then
                                        fps_label.setTextColor(toJavaInt("FFFF9F0A")) 
                                    else
                                        fps_label.setTextColor(toJavaInt("FFFF3B30")) 
                                    end
                                end
                            end)
                        end
                    }))
                    frames = 0
                    lastMillis = currentMillis
                end
                gg.sleep(100) 
            end
        end)
    end
end

local function getGradientShape(colors, radius, strokeColor, strokeWidth)
    local d = luajava.new(GradientDrawable, GradientDrawable.Orientation.TOP_BOTTOM, colors)
    d.setCornerRadius(radius); if strokeColor then d.setStroke(strokeWidth or dp2px(1.8), strokeColor) end; return d
end

local function getAnimatedDrawable(normalColors, radius, strokeColor)
    local states = luajava.new(StateListDrawable)
    states.addState({android.R.attr.state_pressed}, getGradientShape({0xFF5555FF, 0xFFAAAAFF}, radius, 0xFFFFFFFF, dp2px(2.5)))
    states.addState({}, getGradientShape(normalColors, radius, strokeColor)); return states
end

local function syncFlagSecure(lp, window, view)
    if not lp or not window or not view then return end
    local FLAG_SECURE = 8192
    if switchStates["sw_protection"] then
        lp.flags = (lp.flags | FLAG_SECURE)
    else
        lp.flags = (lp.flags & ~FLAG_SECURE)
    end
    pcall(function() window.updateViewLayout(view, lp) end)
end

local function showToast(message, isEnabled)
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            local ok, err = pcall(function()
                local DecelerateInterpolator = luajava.bindClass("android.view.animation.DecelerateInterpolator")
                local AccelerateInterpolator = luajava.bindClass("android.view.animation.AccelerateInterpolator")

                if not context then return end

                local toastFrame = luajava.new(LinearLayout, context)
                toastFrame.setOrientation(0)
                toastFrame.setGravity(17)
                toastFrame.setPadding(dp2px(20), dp2px(12), dp2px(20), dp2px(12))

                local gd = luajava.new(GradientDrawable)
                gd.setColor(toJavaInt("F2101010"))
                gd.setCornerRadius(dp2px(28))
                gd.setStroke(dp2px(1), toJavaInt("30FFFFFF"))
                toastFrame.setBackground(gd)

                local iconView = luajava.new(TextView, context)
                iconView.setTextSize(18)
                iconView.setPadding(0, 0, dp2px(10), 0)

                if FontAwesome then
                    iconView.setTypeface(FontAwesome)
                    iconView.setText(getIcon(isEnabled and 0xf058 or 0xf057))
                    iconView.setTextColor(toJavaInt(isEnabled and "FF34C759" or "FFFF3B30"))
                else
                    iconView.setText(isEnabled and "✓ " or "✗ ")
                    iconView.setTextColor(toJavaInt(isEnabled and "FF34C759" or "FFFF3B30"))
                end

                local toastText = luajava.new(TextView, context)
                toastText.setText(message)
                toastText.setTextColor(0xFFFFFFFF)
                toastText.setTextSize(14)

                toastFrame.addView(iconView)
                toastFrame.addView(toastText)

                local wm = context.getSystemService(context.WINDOW_SERVICE)
                local p = luajava.new(WindowManager.LayoutParams)
                p.height = -2
                p.width = -2
                p.format = -3
                p.type = 2038
                p.flags = 8 | 32 | 262144
                p.gravity = 49
                p.y = dp2px(60)

                wm.addView(toastFrame, p)

                toastFrame.setAlpha(0)
                toastFrame.setTranslationY(-dp2px(80))
                toastFrame.setScaleX(0.85)
                toastFrame.setScaleY(0.85)

                toastFrame.animate()
                    .alpha(1)
                    .translationY(0)
                    .scaleX(1.0)
                    .scaleY(1.0)
                    .setDuration(320)
                    .setInterpolator(luajava.new(DecelerateInterpolator, 1.1))
                    .start()

                thread(function()
                    gg.sleep(2200)
                    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                        run = function()
                            toastFrame.animate()
                                .alpha(0)
                                .translationY(-dp2px(50))
                                .scaleX(0.9)
                                .scaleY(0.9)
                                .setDuration(250)
                                .setInterpolator(luajava.new(AccelerateInterpolator))
                                .withEndAction(luajava.createProxy("java.lang.Runnable", {
                                    run = function()
                                        pcall(function() wm.removeView(toastFrame) end)
                                    end
                                }))
                                .start()
                        end
                    }))
                end)
            end)
        end
    }))
end

-- ============================================
-- 05. FUNÇÕES DA MIRA CROSSHAIR
-- ============================================

function salvarOffsetMira()
    local file = io.open("/sdcard/crosshair_offset.txt", "w")
    if file then
        file:write(OFFSET_X .. "," .. OFFSET_Y)
        file:close()
    end
end

function carregarOffsetMira()
    local file = io.open("/sdcard/crosshair_offset.txt", "r")
    if file then
        local conteudo = file:read("*all")
        file:close()
        local x, y = conteudo:match("(.-),(.*)")
        OFFSET_X = tonumber(x) or -58
        OFFSET_Y = tonumber(y) or -2
    end
    return OFFSET_X, OFFSET_Y
end

function removerMira()
    if miraContainer then
        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
            run = function()
                pcall(function() window.removeView(miraContainer) end)
                miraContainer = nil
                miraView = nil
            end
        }))
    end
    mira_ativa = false
end

function atualizarPosicaoMira()
    if miraContainer and miraParams then
        miraParams.x = OFFSET_X
        miraParams.y = OFFSET_Y
        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
            run = function()
                pcall(function() window.updateViewLayout(miraContainer, miraParams) end)
            end
        }))
    end
    salvarOffsetMira()
    
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            if btn_x_left then btn_x_left.setText("◀ ESQ (" .. OFFSET_X .. ")") end
            if btn_x_right then btn_x_right.setText("DIR (" .. OFFSET_X .. ") ▶") end
            if btn_y_up then btn_y_up.setText("▲ CIMA (" .. OFFSET_Y .. ")") end
            if btn_y_down then btn_y_down.setText("(" .. OFFSET_Y .. ") BAIXO ▼") end
        end
    }))
end

function criarMira()
    removerMira()
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            local container = luajava.new(FrameLayout, context)
            
            local tv = luajava.new(TextView, context)
            tv.setText("+")
            tv.setTextColor(Color.parseColor(MIRA_COR))
            tv.setTextSize(20)
            tv.setGravity(Gravity.CENTER)
            
            local params = luajava.new(FrameLayout.LayoutParams, -2, -2, Gravity.CENTER)
            container.addView(tv, params)
            
            local LayoutParams = luajava.bindClass("android.view.WindowManager$LayoutParams")
            local lp = luajava.new(LayoutParams)
            
            if Build.VERSION.SDK_INT >= 26 then
                lp.type = LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                lp.type = LayoutParams.TYPE_PHONE
            end
            
            lp.format = PixelFormat.RGBA_8888
            lp.flags = LayoutParams.FLAG_NOT_FOCUSABLE
            lp.flags = lp.flags | 16
            lp.gravity = Gravity.CENTER
            lp.width = -2
            lp.height = -2
            lp.x = OFFSET_X
            lp.y = OFFSET_Y
            
            window.addView(container, lp)
            miraContainer = container
            miraParams = lp
            mira_ativa = true
        end
    }))
end

function ativar_mira()
    if not mira_ativa then
        criarMira()
        showToast("Crosshair ATIVADA", true)
    end
end

function desativar_mira()
    if mira_ativa then
        removerMira()
        showToast("Crosshair DESATIVADA", false)
    end
end

function ajustarMiraX(valor)
    OFFSET_X = OFFSET_X + valor
    atualizarPosicaoMira()
    showToast("Mira X: " .. OFFSET_X, true)
end

function ajustarMiraY(valor)
    OFFSET_Y = OFFSET_Y + valor
    atualizarPosicaoMira()
    showToast("Mira Y: " .. OFFSET_Y, true)
end

-- ============================================
-- 06. CALLBACKS DOS SWITCHES
-- Add function Switch
-- ============================================

function ativar_free_shop()
    gg.toast("Free Shop Ativado!")
    showToast("Free Shop Ativado!", true)
end

function desativar_free_shop()
    gg.toast("Free Shop Desativado!")
    showToast("Free Shop Desativado!", false)
end

function ativar_teste()
    gg.toast("Teste Ativado!")
    showToast("Teste Ativado!", true)
end

function desativar_teste()
    gg.toast("Teste Desativado!")
    showToast("Teste Desativado!", false)
end

function ativar_mapa_3()
    gg.toast("Mapa 3 Ativado!")
end

function desativar_mapa_3()
    gg.toast("Mapa 3 Desativado!")
end

-- As funções ativar_teste() e desativar_teste() já estão declaradas acima.
-- Mantemos um único par para evitar sobrescrever callbacks e mensagens.

-- ============================================
-- FUNÇÕES DOS BOTÕES SIMPLES V2 (uma ação)
-- Add function Simples
-- ============================================

function ativar_tp_mina()
    gg.setRanges(gg.REGION_C_DATA | gg.REGION_C_BSS | gg.REGION_OTHER | gg.REGION_CODE_APP | gg.REGION_C_ALLOC)
    gg.clearResults()
    
    local search_value = "4901749241807896576"
    gg.searchNumber(search_value, gg.TYPE_QWORD)
    
    local results = gg.getResults(1)
    if #results > 0 then
        local ACKA01 = results[1].address
        local APEX = {}
        table.insert(APEX, {address = ACKA01 + 0xd4, value = 'C4AA8F6Ch', flags = 4})
        table.insert(APEX, {address = ACKA01 + 0xd4 + 4, value = '452568CEh', flags = 4})
        table.insert(APEX, {address = ACKA01 + 0xd4 + 8, value = '422229DBh', flags = 4})
        
        pcall(function() gg.setValues(APEX) end)
   --     gg.toast("TP Mina Ativado!")
    else
        gg.toast("VALOR NÃO ENCONTRADO")
    end
    gg.clearResults()
end

function ativar_coletar()
    gg.toast("Coletar Ativado!")
end

function ativar_mapa_1()
    gg.toast("Mapa 1 Ativado!")
end

function ativar_mapa_2()
    gg.toast("Mapa 2 Ativado!")
end

-- ============================================
-- FUNÇÃO PARA EDITAR MEMÓRIA (USADO PELO SEEK BAR)
-- ============================================
local function editMemory(lib, offset, vtype, newValue, label, isChecked)
    local status, result = pcall(function()
        local so_list = gg.getRangesList(lib)
        if #so_list == 0 then 
            showToast("ERROR: " .. lib .. " não encontrada", false)
            return false 
        end
        
        local address = so_list[1].start + offset
        local key = lib .. "_" .. string.format("0x%X", offset)
        
        if originalValues[key] == nil then
            local data = gg.getValues({{address = address, flags = vtype}})
            if data and data[1] then
                originalValues[key] = data[1].value
            end
        end
        
        gg.setValues({{address = address, flags = vtype, value = newValue}})

        local msg = label .. (isChecked and " ATIVADO" or " DESATIVADO")
        showToast(msg, isChecked)
        return true
    end)

    if not status then
        showToast("FALHA NA OPERAÇÃO", false)
    end
    return status and result
end

-- ============================================
-- 07. COMPONENTES DO MENU (BOTÕES, SWITCHES E SEEKBARS)
-- ============================================

-- EXECUÇÃO SEGURA DAS FUNÇÕES DO GAMEGUARDIAN
-- Executa buscas fora da thread visual e impede operações simultâneas.
local ggActionBusy = false
local function runGGAction(label, funcao, enabled)
    if type(funcao) ~= "function" then
        showToast(label .. ": FUNÇÃO INDISPONÍVEL", false)
        return
    end
    if ggActionBusy then
        pcall(function() gg.toast("AGUARDE: JÁ EXISTE UMA OPERAÇÃO EM EXECUÇÃO") end)
        return
    end
    ggActionBusy = true
    thread(function()
        local ok, err = pcall(funcao)
        pcall(function() gg.clearResults() end)
        ggActionBusy = false
        if not ok then
            pcall(function() gg.toast("ERRO EM " .. label .. ": " .. tostring(err)) end)
            pcall(function() showToast(label .. " FALHOU - VERIFIQUE O ERRO", false) end)
        elseif enabled ~= nil then
            pcall(function() showToast(label .. (enabled and " ATIVADO" or " DESATIVADO"), enabled) end)
        end
    end)
end

-- 🟢 BOTÃO SIMPLES V2
local function addSimpleButtonV2(parent, label, funcao)
    local container = luajava.new(LinearLayout, context)
    container.setOrientation(0)
    container.setGravity(16)
    container.setPadding(dp2px(12), dp2px(10), dp2px(12), dp2px(10))
    container.setBackground(getGradientShape({toJavaInt("FF0A0A0A"), toJavaInt("FF111111")}, dp2px(10), toJavaInt("FF222222"), dp2px(1)))
    container.setClickable(true)
    
    local iconView = luajava.new(TextView, context)
    iconView.setTextColor(toJavaInt("FF007AFF")) 
    iconView.setTextSize(16)
    iconView.setPadding(0, 0, dp2px(10), 0)
    
    if FontAwesome then
        iconView.setTypeface(FontAwesome)
        iconView.setText(utf8.char(0xF0A4))
    else
        iconView.setText("▶")
    end

    local txt = luajava.new(TextView, context)
    txt.setTextColor(-1)
    txt.setTextSize(10.5)
    txt.setText(label)
    txt.setLayoutParams(luajava.new(LinearLayoutParams, 0, -2, 1))
    
    container.addView(iconView)
    container.addView(txt)
    
    container.setOnClickListener(luajava.createProxy("android.view.View$OnClickListener", {
        onClick = function()
            runGGAction(label, funcao, true)
        end
    }))
    
    parent.addView(container)
    local lp_res = luajava.new(LinearLayoutParams, -1, -2)
    lp_res.setMargins(0, 0, 0, dp2px(8))
    container.setLayoutParams(lp_res)
end

-- 🟢 BOTÃO SWITCH
local function addStyledSwitch(parent, label, key, ativar_func, desativar_func)
    local container = luajava.new(LinearLayout, context)
    container.setOrientation(0)
    container.setGravity(16)
    container.setPadding(dp2px(12), dp2px(10), dp2px(12), dp2px(10))
    container.setBackground(getGradientShape({toJavaInt("FF0A0A0A"), toJavaInt("FF111111")}, dp2px(10), toJavaInt("FF222222"), dp2px(1)))
    
    local textContainer = luajava.new(LinearLayout, context)
    textContainer.setLayoutParams(luajava.new(LinearLayoutParams, 0, -2, 1))
    textContainer.setGravity(16)

    local iconView = luajava.new(TextView, context)
    iconView.setTextColor(toJavaInt("FF007AFF")) 
    iconView.setTextSize(16)
    iconView.setPadding(0, 0, dp2px(10), 0)
    
    if FontAwesome then
        iconView.setTypeface(FontAwesome)
        local iconCode = FontIcon.switches[key] or FontIcon.menu['power-off']  
        iconView.setText(utf8.char(iconCode))
    end

    local txt = luajava.new(TextView, context)
    txt.setTextColor(-1)
    txt.setTextSize(10.5)
    txt.setText(label)
    
    textContainer.addView(iconView)
    textContainer.addView(txt)
    
    local sw = luajava.new(Switch, context)
    sw.setChecked(switchStates[key] or false)

    local function applyColors(sView, isChecked)
        pcall(function()
            local thumbColor = toJavaInt("FFFFFFFF")
            local trackColor = isChecked and toJavaInt("FF34C759") or toJavaInt("FF39393D")
            sView.getThumbDrawable().setColorFilter(thumbColor, PorterDuff.Mode.SRC_IN)
            sView.getTrackDrawable().setColorFilter(trackColor, PorterDuff.Mode.SRC_IN)
        end)
    end

    applyColors(sw, sw.isChecked())

    sw.setOnCheckedChangeListener(luajava.createProxy("android.widget.CompoundButton$OnCheckedChangeListener", { 
        onCheckedChanged = function(_, isChecked) 
            switchStates[key] = isChecked 
            applyColors(sw, isChecked)

            -- FAZENDA DE SWITCHES
            if key == "sw_fps" then
                toggleFpsCounter(isChecked)
            elseif key == "sw_protection" then
                syncFlagSecure(lp, window, view)
            elseif key == "sw_Free_Shop" then
                if isChecked then ativar_free_shop() else desativar_free_shop() end
            elseif key == "sw_teste" then
                if isChecked then ativar_teste() else desativar_teste() end
            elseif key == "sw_mira" then
                carregarOffsetMira()
                if isChecked then
                    ativar_mira()
                else
                    desativar_mira()
                end
            elseif ativar_func then
                local callback = isChecked and ativar_func or desativar_func
                if callback then
                    runGGAction(label, callback, isChecked)
                else
                    showToast(label .. (isChecked and " ATIVADO" or " DESATIVADO"), isChecked)
                end
            else
                showToast(label .. (isChecked and " ATIVADO" or " DESATIVADO"), isChecked)
            end
        end 
    }))

    container.addView(textContainer)
    container.addView(sw)
    parent.addView(container)
    
    local lp_res = luajava.new(LinearLayoutParams, -1, -2)
    lp_res.setMargins(0, 0, 0, dp2px(8))
    container.setLayoutParams(lp_res)
    
    return sw
end

-- Botões pequenos para ajustar a mira
local function addMiraAdjustButtons(parent)
    local buttonContainer = luajava.new(LinearLayout, context)
    buttonContainer.setOrientation(0)
    buttonContainer.setGravity(16)
    buttonContainer.setPadding(dp2px(5), dp2px(5), dp2px(5), dp2px(10))
    
    local function createSmallButton(text, bgColor, onClickFunc)
        local btn = luajava.new(Button, context)
        btn.setText(text)
        btn.setTextSize(10)
        btn.setTextColor(toJavaInt("FFFFFFFF"))
        
        local bg = luajava.new(GradientDrawable)
        bg.setShape(GradientDrawable.RECTANGLE)
        bg.setColor(bgColor)
        bg.setCornerRadius(dp2px(8))
        btn.setBackground(bg)
        
        local lp = luajava.new(LinearLayoutParams, 0, dp2px(35), 1)
        lp.setMargins(dp2px(3), 0, dp2px(3), 0)
        btn.setLayoutParams(lp)
        
        btn.setOnClickListener(luajava.createProxy("android.view.View$OnClickListener", {
            onClick = function() onClickFunc() end
        }))
        
        return btn
    end
    
    -- EQUERDA(-4) / DIREITA(5) / BAIXO(5) / CIMA(-4)
    local btnLeft = createSmallButton("◀", 0xFF444444, function() ajustarMiraX(-4) end)
    local btnRight = createSmallButton("▶", 0xFF444444, function() ajustarMiraX(5) end)
    local btnDown = createSmallButton("▼", 0xFF444444, function() ajustarMiraY(5) end)
    local btnUp = createSmallButton("▲", 0xFF444444, function() ajustarMiraY(-4) end)
    
    buttonContainer.addView(btnLeft)
    buttonContainer.addView(btnRight)
    buttonContainer.addView(btnDown)
    buttonContainer.addView(btnUp)
    
    parent.addView(buttonContainer)
    
    local infoContainer = luajava.new(LinearLayout, context)
    infoContainer.setOrientation(0)
    infoContainer.setGravity(16)
    infoContainer.setPadding(dp2px(5), 0, dp2px(5), dp2px(8))
    
    local xLabel = luajava.new(TextView, context)
    xLabel.setText("X: " .. OFFSET_X)
    xLabel.setTextColor(toJavaInt("88FFFFFF"))
    xLabel.setTextSize(9)
    xLabel.setLayoutParams(luajava.new(LinearLayoutParams, 0, -2, 1))
    xLabel.setGravity(17)
    
    local yLabel = luajava.new(TextView, context)
    yLabel.setText("Y: " .. OFFSET_Y)
    yLabel.setTextColor(toJavaInt("88FFFFFF"))
    yLabel.setTextSize(9)
    yLabel.setLayoutParams(luajava.new(LinearLayoutParams, 0, -2, 1))
    yLabel.setGravity(17)
    
    infoContainer.addView(xLabel)
    infoContainer.addView(yLabel)
    parent.addView(infoContainer)
    
    _G.updateMiraLabels = function()
        xLabel.setText("X: " .. OFFSET_X)
        yLabel.setText("Y: " .. OFFSET_Y)
    end
    
    local originalAjustarX = ajustarMiraX
    local originalAjustarY = ajustarMiraY
    ajustarMiraX = function(valor)
        originalAjustarX(valor)
        if _G.updateMiraLabels then _G.updateMiraLabels() end
    end
    ajustarMiraY = function(valor)
        originalAjustarY(valor)
        if _G.updateMiraLabels then _G.updateMiraLabels() end
    end
    
    return buttonContainer
end

local function addStyledSeekBar(parent, label, min, max, key)
    local container = luajava.new(LinearLayout, context)
    container.setOrientation(1)
    container.setPadding(dp2px(12), dp2px(10), dp2px(12), dp2px(10))
    container.setBackground(getGradientShape({toJavaInt("FF0A0A0A"), toJavaInt("FF111111")}, dp2px(10), toJavaInt("FF222222"), dp2px(1)))
    
    local header = luajava.new(LinearLayout, context)
    header.setOrientation(0)
    header.setGravity(16)
    
    local iconView = luajava.new(TextView, context)
    iconView.setTextColor(toJavaInt("FF007AFF")) 
    iconView.setTextSize(14)
    iconView.setPadding(0, 0, dp2px(8), 0)
    
    if FontAwesome then
        iconView.setTypeface(FontAwesome)
        local iconCode = FontIcon.seekbars[key] or FontIcon.menu['loading'] 
        iconView.setText(utf8.char(iconCode))
    end
    
    local txt = luajava.new(TextView, context)
    txt.setTextColor(toJavaInt("FFBBBBBB"))
    txt.setTextSize(10.5)
    txt.setText(label)
    txt.setLayoutParams(luajava.new(LinearLayoutParams, 0, -2, 1))
    
    local valTxt = luajava.new(TextView, context)
    valTxt.setTextColor(toJavaInt("FF34C759")) 
    valTxt.setTextSize(10.5)
    valTxt.setText(tostring(switchStates[key] or min))
    
    header.addView(iconView)
    header.addView(txt)
    header.addView(valTxt)
    container.addView(header)
    
    local sb = luajava.new(SeekBar, context)
    sb.setMax(max - min)
    sb.setProgress((switchStates[key] or min) - min)
    
    pcall(function()
        sb.getThumb().setColorFilter(toJavaInt("FFFFFFFF"), PorterDuff.Mode.SRC_IN)
        sb.getProgressDrawable().setColorFilter(toJavaInt("FF34C759"), PorterDuff.Mode.SRC_IN)
    end)
    
    sb.setOnSeekBarChangeListener(luajava.createProxy("android.widget.SeekBar$OnSeekBarChangeListener", {
        onProgressChanged = function(_, progress, fromUser)
            local actualValue = progress + min
            valTxt.setText(tostring(actualValue))
            
            if fromUser then
                switchStates[key] = actualValue
                local action = OFFSET.SEKBAR[key]
                if action then
                    thread(function()
                        local valueToApply = actualValue
                        local addrKey = action.lib .. "_" .. string.format("0x%X", action.offset)
                        
                        if actualValue == min and originalValues[addrKey] ~= nil then
                            valueToApply = originalValues[addrKey]
                        end

                        editMemory(action.lib, action.offset, action.type, valueToApply, label, true)
                    end)
                end
            end
        end,
        onStartTrackingTouch = function() end,
        onStopTrackingTouch = function(bar)
            local current = bar.getProgress() + min
            if current == min then
                showToast(label .. " RESTABELECIDO", false)
            end
        end
    }))
    
    container.addView(sb)
    parent.addView(container)
    
    local lp_res = luajava.new(LinearLayoutParams, -1, -2)
    lp_res.setMargins(0, 0, 0, dp2px(8))
    container.setLayoutParams(lp_res)
end

-- ============================================
-- 08. CONTEÚDO DAS ABAS
-- ============================================
function updateTabContent(title)
    activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
        run = function()
            pcall(function()
                if menu_title then 
                    menu_title.setText(title)
                    applyIcons() 
                end

                if content_derecha then
                    content_derecha.removeAllViews()
local data = {
                        PLAYER = {
                            {name = "AIMBOT BRAÇO BUGADO", type = "switch", key = "LM_AIMBOT", ativar = nightmode, desativar = nightmode},
                            {name = "RELAR KIT 3 SEGUNDOS", type = "switch", key = "LM_CAMERA_FOV", ativar = nightmode222, desativar = nightmode222},
                            {name = "CÂMERA FOV", type = "switch", key = "LM_KIT", ativar = savefast, desativar = savefast}
                        },
                        ANTENA = {
                            {name = "ANTENA CORPO", type = "switch", key = "LM_ANT_CORPO", ativar = antena, desativar = antena},
                            {name = "ANTENA CABEÇA FINA", type = "switch", key = "LM_ANT_CABECA", ativar = antenaf, desativar = antenaf},
                            {name = "ANTENA OMBRO", type = "switch", key = "LM_ANT_OMBRO", ativar = antenah, desativar = antenah},
                            {name = "ANTENA BRAÇO", type = "switch", key = "LM_ANT_BRACO", ativar = antenab, desativar = antenab},
                            {name = "ANTENA LASER ROXA", type = "switch", key = "LM_ANT_LASER", ativar = item, desativar = item},
                            {name = "MIRA HD", type = "switch", key = "LM_MIRA_HD", ativar = a3, desativar = a3},
                            {name = "BONECO BRANCO", type = "switch", key = "LM_BONECO_BRANCO", ativar = white, desativar = white},

                        },
                        CHEATS = {
                            {name = "SPEED HACK 100X", type = "switch", key = "LM_SPEEDHACK", ativar = speedhk, desativar = speedhk},
                            {name = "SPEED PLAYER 20X", type = "switch", acao = speed20x},
                            {name = "SPEED PLAYER 30X", type = "switch", acao = speed30x},
                            {name = "SPEED PLAYER 50X", type = "switch", acao = speed50x},
                            {name = "SPEED PLAYER 100X", type = "switch", acao = speed100x},
                            {name = "MATAR COM PUNHO", type = "switch", acao = a1}
                        },
                        REGEDIT = {
                            {name = "REGEDIT HS 50% #1", type = "switch", key = "LM_REGEDIT_HS50_1", ativar = v1, desativar = v1},
                            {name = "REGEDIT HS 60% #2", type = "switch", key = "LM_REGEDIT_HS60_2", ativar = v2, desativar = v2},
                            {name = "REGEDIT RAGE HS 80% #1", type = "switch", key = "LM_REGEDIT_RAGE80_1", ativar = v3, desativar = v3},
                            {name = "REGEDIT RAGE HS 90% #2", type = "switch", key = "LM_REGEDIT_RAGE90_2", ativar = v4, desativar = v4},
                            {name = "NO RECOIL", type = "switch", key = "LM_REGEDIT_RAGE90_2", ativar = a6, desativar = a6}
                        },
                        MAPAS = {
                            {name = "NOME DOS NPCS", type = "switch", key = "LM_NOME_NPCS", ativar = a2, desativar = a2},
                            {name = "ANTIBAN VIP PRO", type = "switch", key = "LM_ANTIBAN_VIP_PRO", ativar = a4, desativar = a4},
                            {name = "APAGAR DENÚNCIAS", type = "switch", key = "LM_APAGAR_DENUNCIAS", ativar = a5, desativar = a5}
                        },
                        SETTINGS = {
                            {name = "Ant Recording", type = "switch", key = "sw_protection"},
                            {name = "Show FPS", type = "switch", key = "sw_fps"},
                            {name = "Crosshair", type = "switch", key = "sw_mira", ativar = ativar_mira, desativar = desativar_mira}
                        }
                    }


                    local options = data[title] or {}

                    for _, item in ipairs(options) do
                        if item.type == "seek" then
                            addStyledSeekBar(content_derecha, item.name, item.min, item.max, item.key)
                        elseif item.type == "simple_v2" then
                            addSimpleButtonV2(content_derecha, item.name, item.acao)
                        else
                            if item.ativar then
                                addStyledSwitch(content_derecha, item.name, item.key, item.ativar, item.desativar)
                            else
                                addStyledSwitch(content_derecha, item.name, item.key, nil, nil)
                            end
                        end
                    end
                    
                    if title == "CONFIG" then
                        addMiraAdjustButtons(content_derecha)
                    end
                    
                    content_derecha.invalidate()
                    content_derecha.requestLayout()
                end
            end)
        end
    }))
end

local blue_pure, pure_white, red_grad = {toJavaInt("FF00008B"), toJavaInt("FF0000FF")}, 0xFFFFFFFF, {toJavaInt("FFED213A"), toJavaInt("FF93291E")}
local red_transparent = {toJavaInt("66FF0000"), toJavaInt("44FF0000")} 
local red_pure = toJavaInt("FFFF0000")

-- ============================================
-- 09. LAYOUT PRINCIPAL
-- ============================================
local mainLayout = {
    FrameLayout; id="root"; layout_width="-1"; layout_height="-1"; background="#00000000"; 
    {
        FrameLayout; id="mFrame"; tag="main_frame"; layout_width="-1"; layout_height="-1"; layout_margin="4dp"; 
        {
            LinearLayout; id="main_content"; orientation="horizontal"; layout_width="-1"; layout_height="-1"; padding="10dp"; visibility=4;
            {
                LinearLayout; id="side_container"; orientation="vertical"; layout_width="-2"; layout_height="-1"; gravity="1";
                { ImageView; id="img_banner"; layout_width="55dp"; layout_height="55dp"; clickable=true; layout_gravity="1"; background="#00000000"; };
                {
                    LinearLayout; id="sidebar_content"; orientation="vertical"; layout_width="110dp"; layout_height="-1";
                    { TextView; id="shimmer_main_title", text="LM TEAM PLUS V5"; textColor="-1"; textSize="11sp"; textStyle="bold"; layout_width="-1"; layout_marginTop="6dp"; gravity="1"; };
                    { View; layout_width="-1"; layout_height="2dp"; background=getGradientShape({toJavaInt("FF0000FF"), 0}, 0); layout_marginTop="8dp"; layout_marginBottom="12dp"; };
                    {
                        ScrollView; layout_width="-1"; layout_height="0dp"; layout_weight="1"; fillViewport=true;
                        {
                            LinearLayout; orientation="vertical"; layout_width="-1"; layout_height="-2";
                            { TextView; id="tab_player", text="PLAYER", layout_width="-1", layout_height="35dp", gravity="17", textColor="-1", textSize="9sp", textStyle="bold", layout_marginBottom="8dp", layout_marginHorizontal="8dp", clickable=true, background=getAnimatedDrawable(blue_pure, dp2px(10), pure_white) },
                            { TextView; id="tab_visual", text="ANTENA", layout_width="-1", layout_height="35dp", gravity="17", textColor="-1", textSize="9sp", textStyle="bold", layout_marginBottom="8dp", layout_marginHorizontal="8dp", clickable=true, background=getAnimatedDrawable(blue_pure, dp2px(10), pure_white) },
                            { TextView; id="tab_mapas", text="BTPASS", layout_width="-1", layout_height="35dp", gravity="17", textColor="-1", textSize="9sp", textStyle="bold", layout_marginBottom="8dp", layout_marginHorizontal="8dp", clickable=true, background=getAnimatedDrawable(blue_pure, dp2px(10), pure_white) },
                            { TextView; id="tab_cheats", text="CHEATS", layout_width="-1", layout_height="35dp", gravity="17", textColor="-1", textSize="9sp", textStyle="bold", layout_marginBottom="8dp", layout_marginHorizontal="8dp", clickable=true, background=getAnimatedDrawable(blue_pure, dp2px(10), pure_white) },
                            { TextView; id="tab_regedit", text="REGEDIT", layout_width="-1", layout_height="35dp", gravity="17", textColor="-1", textSize="9sp", textStyle="bold", layout_marginBottom="8dp", layout_marginHorizontal="8dp", clickable=true, background=getAnimatedDrawable(blue_pure, dp2px(10), pure_white) },
                        };
                    };
                    { TextView; id="btn_exit", text="FECHAR", textColor="-1"; textSize="9sp"; textStyle="bold"; gravity="17"; layout_width="-1"; layout_height="30dp"; layout_marginBottom="10dp"; layout_marginHorizontal="12dp"; clickable=true; background=getGradientShape(red_transparent, dp2px(12), red_pure, dp2px(1.5)); };
                };
            };
            { LinearLayout; id="separator_container"; layout_width="0dp"; layout_weight="0.05"; layout_height="-1"; gravity="17"; { View; id="separator_line"; layout_width="1dp"; layout_height="-1"; background="#44FFFFFF"; }; };
            {
                LinearLayout; id="container_right"; orientation="vertical"; layout_width="0dp"; layout_weight="1"; layout_height="-1"; layout_marginLeft="5dp";
                {
                    LinearLayout; layout_width="-1"; layout_height="-2"; orientation="vertical";
                    { 
                        LinearLayout; layout_width="-1"; layout_height="35dp"; orientation="horizontal"; gravity="16"; 
                        { TextView; id="menu_title"; text="PLAYER"; textColor="-1"; textSize="13sp"; textStyle="bold"; layout_weight="1"; gravity="17"; }; 
                        { TextView; id="btn_settings_nut"; text="?"; textColor="-1"; textSize="22sp"; clickable=true; paddingRight="10dp"; }; 
                    };
                    { View; layout_width="-1"; layout_height="1dp"; background="#66FFFFFF"; layout_marginBottom="5dp"; };
                };
                { FrameLayout; id="matrix_container"; layout_width="-1"; layout_height="25dp"; clipChildren=true; { TextView; id="fixed_info", text="CRIADO POR LEO MODZ", textColor="#FFFFFF", textSize="11sp", textStyle="bold", gravity="16", layout_width="-2", layout_height="-1", singleLine="true", ellipsize="none" }; };
                { ScrollView; id="scroll_content"; layout_width="-1"; layout_height="-1"; 
                    { LinearLayout; orientation="vertical"; id="content_derecha"; layout_width="-1"; layout_height="-2"; padding="10dp"; };
                };
            };
        };
        {
            FrameLayout; id="global_splash"; layout_width="-1"; layout_height="-1";
            {
                LinearLayout; orientation="vertical"; gravity="17"; layout_width="-1"; layout_height="-1";
                { TextView; id="splash_icon"; textSize="40sp"; textColor="-1"; gravity="17"; };
                { TextView; id="splash_status"; text="SISTEMA LM TEAM PLUS V5"; textSize="11sp"; textColor="0xCCFFFFFF"; layout_marginTop="15dp"; textStyle="bold"; };
            };
        };
    };
}

-- ============================================
-- 10. INICIALIZAÇÃO E EVENTOS DA INTERFACE
-- ============================================
invoke = function()
    pcall(function()
        view = loadlayout(mainLayout); updateTabContent("PLAYER")
        
        carregarOffsetMira()
        
        pcall(function()
            local menuRadius = dp2px(12)
            local contentFrame = view.findViewWithTag("main_frame")
            if contentFrame then
                local backBg = luajava.new(GradientDrawable)
                backBg.setColor(toJavaInt("F2000000"))
                backBg.setCornerRadius(menuRadius)
                local strokeBg = luajava.new(GradientDrawable)
                strokeBg.setCornerRadius(menuRadius)
                strokeBg.setStroke(dp2px(1), toJavaInt("30FFFFFF"))
                contentFrame.setBackground(luajava.new(LayerDrawable, {backBg, strokeBg}))
            end
        end)
        
        lp = luajava.new(LayoutParams)
        lp.type = (Build.VERSION.SDK_INT >= 26) and 2038 or 2002
        lp.format = -3
        lp.gravity = 17 
        lp.x = 0
        lp.y = 0
        lp.flags = 8 | 32
        lp.width = dp2px(400)
        lp.height = dp2px(375)
        
        local th = luajava.createProxy("android.view.View$OnTouchListener", { 
            onTouch = function(v, e) 
                local action = e.getAction()
                if action == MotionEvent.ACTION_DOWN then sX, sY, oX, oY, mov = e.getRawX(), e.getRawY(), lp.x, lp.y, false; return true 
                elseif action == MotionEvent.ACTION_MOVE then 
                    local dX, dY = e.getRawX() - sX, e.getRawY() - sY
                    if math.abs(dX) > 10 or math.abs(dY) > 10 then mov, lp.x, lp.y = true, oX + dX, oY + dY; window.updateViewLayout(view, lp) end
                    return true 
                elseif action == MotionEvent.ACTION_UP then 
                    if not mov then 
                        if v == img_banner then img_banner.performClick() 
                        elseif v == btn_settings_nut then btn_settings_nut.performClick() 
                        end 
                    end
                    return true 
                end
                return false 
            end 
        })
        
        root.setOnTouchListener(th)
        img_banner.setOnTouchListener(th)
        btn_settings_nut.setOnTouchListener(th)
        
        tab_player.onClick = function() updateTabContent("PLAYER"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        tab_visual.onClick = function() updateTabContent("ANTENA"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        tab_mapas.onClick = function() updateTabContent("MAPAS"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        tab_cheats.onClick = function() updateTabContent("CHEATS"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        tab_regedit.onClick = function() updateTabContent("REGEDIT"); lp.flags = 8 | 32; syncFlagSecure(lp, window, view) end
        
        btn_exit.onClick = function()
            menu_active = false
            show_fps_enabled = false
            removerMira()
            
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
                run = function()
                    pcall(function()
                        if view then view.clearAnimation() end
                        
                        if fps_view then 
                            window.removeView(fps_view)
                            fps_view = nil 
                        end
                        if view then 
                            window.removeView(view)
                            view = nil 
                        end
                        
                        Lock.unUi()
                    end)
                end
            }))

            thread(function()
                gg.sleep(300)
                pcall(function() gg.setVisible(true) end)
                gg.sleep(100)
                pcall(function() os.exit() end)
            end)
        end

        btn_settings_nut.onClick = function()
            pcall(function() 
                content_derecha.removeAllViews()
                menu_title.setText("CONFIG")
                applyIcons()
                        
                addStyledSwitch(content_derecha, "ANT GRAVAÇÃO", "sw_protection", nil, nil)
                addStyledSwitch(content_derecha, "MOSTRAR FPS", "sw_fps", nil, nil)
                addStyledSwitch(content_derecha, "CROSSHAIR", "sw_mira", ativar_mira, desativar_mira)
                
                addMiraAdjustButtons(content_derecha)
                
                local infoText = luajava.new(TextView, context)
                infoText.setText("LM TEAM PLUS V5")
                infoText.setTextColor(toJavaInt("88FFFFFF")) 
                infoText.setTextSize(9)
                infoText.setGravity(17) 
                infoText.setPadding(0, dp2px(10), 0, dp2px(10))
                infoText.setTypeface(Typeface.create("sans-serif-light", Typeface.BOLD))
                
                local lp_info = luajava.new(LinearLayoutParams, -1, -2)
                infoText.setLayoutParams(lp_info)
                
                content_derecha.addView(infoText)
                lp.flags = 8 | 32; syncFlagSecure(lp, window, view)
                content_derecha.requestLayout()
            end)
        end
        
        img_banner.onClick = function()
            is_minimized = not is_minimized; local state = is_minimized and 8 or 0
            sidebar_content.setVisibility(state); container_right.setVisibility(state); separator_container.setVisibility(state)
            local border = root.findViewWithTag("border_layer"); if border then border.setVisibility(state) end
            lp.flags = 8 | 32
            if switchStates["sw_protection"] then lp.flags = lp.flags | 8192 end
            if is_minimized then 
                mFrame.setBackground(nil); 
                mFrame.setLayoutParams(luajava.new(FrameLayoutParams, -1, -1)); 
                main_content.setPadding(0, 0, 0, 0); 
                lp.width, lp.height = dp2px(60), dp2px(60) 
            else 
                pcall(function()
                    local menuRadius = dp2px(12)
                    local contentFrame = root.findViewWithTag("main_frame")
                    if contentFrame then
                        local backBg = luajava.new(GradientDrawable)
                        backBg.setColor(toJavaInt("F2000000"))
                        backBg.setCornerRadius(menuRadius)
                        local strokeBg = luajava.new(GradientDrawable)
                        strokeBg.setCornerRadius(menuRadius)
                        strokeBg.setStroke(dp2px(1), toJavaInt("30FFFFFF"))
                        contentFrame.setBackground(luajava.new(LayerDrawable, {backBg, strokeBg}))
                    end
                end)
                main_content.setPadding(dp2px(10), dp2px(10), dp2px(10), dp2px(10)); 
                lp.width, lp.height = dp2px(380), dp2px(340) 
            end
            window.updateViewLayout(view, lp)
        end
        
        thread(function()
            local retryButton
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() 
                if global_splash then
                    local splashBg = luajava.new(GradientDrawable); splashBg.setColor(toJavaInt("FB0A0A0A")); splashBg.setCornerRadius(dp2px(18)); splashBg.setStroke(dp2px(1.2), toJavaInt("22FFFFFF")); global_splash.setBackground(splashBg)
                    local barTrack = luajava.new(View, context); local trackShape = luajava.new(GradientDrawable); trackShape.setColor(toJavaInt("15FFFFFF")); trackShape.setCornerRadius(dp2px(2)); barTrack.setBackground(trackShape); global_splash.addView(barTrack, FrameLayoutParams(dp2px(220), dp2px(4), 17))
                    progressBar = luajava.new(View, context); local progressShape = luajava.new(GradientDrawable); progressShape.setColor(toJavaInt("FFFFFFFF")); progressShape.setCornerRadius(dp2px(2)); progressBar.setBackground(progressShape); global_splash.addView(progressBar, FrameLayoutParams(0, dp2px(4), 17))
                    
                    retryButton = luajava.new(Button, context); retryButton.setText("TRY AGAIN"); retryButton.setVisibility(8); retryButton.setTextColor(toJavaInt("FFFFFFFF"))
                    local btnBg = luajava.new(GradientDrawable); btnBg.setColor(toJavaInt("33FF4444")); btnBg.setCornerRadius(dp2px(10)); btnBg.setStroke(dp2px(1), toJavaInt("66FF4444")); retryButton.setBackground(btnBg)
                    global_splash.addView(retryButton, FrameLayoutParams(dp2px(140), dp2px(38), 17))
                    retryButton.setOnClickListener(luajava.createProxy("android.view.View$OnClickListener", { onClick = function(v) v.setVisibility(8); if splash_status then splash_status.setText("RECONNECTING...") end; load_assets_direct() end }))
                end
            end }))
            
            local progress = 0
            while menu_active do
                local done = assets_loaded.image and assets_loaded.font; local err = assets_error.image or assets_error.font
                if not done and not err then if progress < 98 then progress = progress + 0.8 end elseif done then progress = 100 end
                activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() 
                    if progressBar then progressBar.getLayoutParams().width = dp2px((progress / 100) * 220); progressBar.requestLayout() end
                    if splash_status then if done then splash_status.setText("Starting UI") elseif err then splash_status.setText("Connection error"); if retryButton then retryButton.setVisibility(0) end else splash_status.setText("Downloading Resources: " .. math.floor(progress) .. "%") end end
                end }))
                if done then 
                    pcall(function() 
                        if Point and Point.f then
                            gg.setVisible(false)
                            Point.f() 
                        end 
                    end)
                    break 
                end; gg.sleep(80)
            end
            gg.sleep(800)
            
            activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function() 
                if global_splash then 
                    ObjectAnimator.ofFloat(global_splash, "alpha", 1, 0).setDuration(500).start()
                    thread(function()
                        gg.sleep(500); activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", { run = function()
                            global_splash.setVisibility(8); global_splash.removeAllViews() 
                            if main_content then main_content.setVisibility(0); main_content.setAlpha(0); ObjectAnimator.ofFloat(main_content, "alpha", 0, 1).setDuration(500).start() end
                        end }))
                    end)
                end
            end }))
        end)
        
        window.addView(view, lp)
        load_assets_direct()
    end)
end

-- ============================================
-- 11. FUNÇÕES DE MEMÓRIA E RECURSOS LM TEAM V4
-- ============================================
local memFrom, memTo, lib, num, lim, results, src, ok = 0, -1, nil, 0, 32, {}, nil, false
function name(n)
if lib ~= n then
lib = n
local ranges = gg.getRangesList(lib)
if #ranges == 0 then

else
memFrom = ranges[1].start
memTo = ranges[#ranges]["end"]
 end
end
end
function hex2tbl(hex)
local ret = {}
hex:gsub("%S%S", function(ch)
ret[#ret + 1] = ch
return ""
end)
return ret
end
function original(orig)
local tbl = hex2tbl(orig)
local len = #tbl
if len == 0 then
return
end
local used = len
if len > lim then
used = lim
end
local s = ""
for i = 1, used do
if i ~= 1 then
s = s .. ";"
end
local v = tbl[i]
if v == "??" or v == "**" then
v = "0~~0"
end
s = s .. v .. "r"
end
s = s .. "::" .. used
gg.searchNumber(s, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, memFrom, memTo)
if len > used then
for i = used + 1, len do
local v = tbl[i]
if v == "??" or v == "**" then
v = 256
else
v = ("0x" .. v) + 0
if v > 127 then
v = v - 256
end
end
tbl[i] = v
end
end
local found = gg.getResultCount()
results = {}
local count = 0
local checked = 0
while not (found <= checked) do
local all = gg.getResults(8)
local total = #all
local start = checked
if total < checked + used then
break
end
for i, v in ipairs(all) do
v.address = v.address + myoffset
end
gg.loadResults(all)
while total > start do
local good = true
local offset = all[1 + start].address - 1
if len > used then
local get = {}
for i = lim + 1, len do
get[i - lim] = {
address = offset + i,
flags = gg.TYPE_BYTE,
value = 0
}
end
get = gg.getValues(get)
for i = lim + 1, len do
local ch = tbl[i]
if ch ~= 256 and get[i - lim].value ~= ch then
good = false
break
end
end
end
if good then
count = count + 1
results[count] = offset
checked = checked + used
else
local del = {}
for i = 1, used do
del[i] = all[i + start]
end
gg.removeResults(del)
end
start = start + used
end
end
end
function replaced(repl)
num = num + 1
local tbl = hex2tbl(repl)
if src ~= nil then
local source = hex2tbl(src)
for i, v in ipairs(tbl) do
if v ~= "??" and v ~= "**" and v == source[i] then
tbl[i] = "**"
end
end
src = nil
end
local cnt = #tbl
local set = {}
local s = 0
for _, addr in ipairs(results) do
for i, v in ipairs(tbl) do
if v ~= "??" and v ~= "**" then
s = s + 1
set[s] = {
address = addr + i,
value = v .. "r",
flags = gg.TYPE_BYTE
}
 end
end
end
if s ~= 0 then
gg.setValues(set)
end
ok = true
end


gg.setVisible(false)

  
function Main()
  menu = gg.choice({ 
    "Matar Com Punho Beta🤜",
    "Nome dos NPCs👤",
    "Mira HD📀",
    "🛡️Antiban VIP PRO[70%]🛡️",
    "🏷️Apagar Denúncias 🏷️",
    "No Recoil Teste ➖️",
    "Menu Antenas 📡",
    "Menu Regedit 👽",
    "Menu Speed Player 🏃‍♂️",
    "Menu Speed Hack 🏃‍♂️";
    "Menu Aimbot 👺",
    "Camera Fov 🦅",
    "Relar Kit 3 Segundos💊 ",
    "Boneco Branco ⛄️",
    "SAIR ❌️"                        
  }, nil, '💎SCRIPT  PLUS V5 CRIADOR @LEO MODZ 💎')
  
  if menu == nil then 
  else 
    if menu == 1 then a1() end 
    if menu == 2 then a2() end 
    if menu == 3 then a3() end 
    if menu == 4 then a4() end 
    if menu == 5 then a5() end 
    if menu == 6 then a6() end 
    if menu == 7 then antenas() end
    if menu == 8 then reg() end
    if menu == 9 then speedplayer() end
    if menu == 11 then menuaimbot() end
    if menu == 12 then savefast() end
    if menu == 13 then nightmode222() end
    if menu == 14 then white() end
    if menu == 15 then a9() end
  end 
  XGCK = -1 
end

function a1()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("1057048494;1054951342;1053273620", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.getResults(20000)
gg.editAll("-20000", gg.TYPE_DWORD)
gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("-1.30928164e25;-3.69511377e20;1.25206298e-38;0.00001", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.refineNumber("0.00001", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(10, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("1", gg.TYPE_FLOAT)
gg.clearResults()
gg.processResume()
gg.setRanges(gg.REGION_CODE_APP)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("75;40::5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("40", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.getResults(20)
gg.editAll("1876925179", gg.TYPE_FLOAT)
gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("75;40::5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("40", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.getResults(20)
gg.editAll("91500", gg.TYPE_FLOAT)
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("1057048494", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.getResults(205, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-2000000", gg.TYPE_DWORD)
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("3DB851ECh;3F800000h;420000h;40A00000h;40133333h", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.refineNumber("1075000115", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1, 0)
gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("-5", gg.TYPE_DWORD)
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("1.35000002384", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.getResults(1000)
gg.editAll("100", gg.TYPE_FLOAT)
gg.clearResults()
gg.toast("MATAR COM PUNHO ON")
end

function a2()
gg.getTargetInfo()
gg.getRangesList("/data/app/com.tencent.mobileqqh--K8zkJPwMl08Od8d7X-2nQ==/lib/arm/libil2cpp.so")
gg.clearResults()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("Q00000000\"!\"0000\"InGame/CapsuleHumanSniperCollider\"00000000000000000000", gg.TYPE_BYTE, nil, nil, nil, nil)
gg.getResults(1000)
gg.editAll("Q00000000\"&\"0000\"InGame/NetworkAIPawn/NetworkAIPartyNPC\"", 1)
gg.clearResults()
gg.toast("NPC NAME ON")
end

function a3()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("0.84705883265;0.5;0.5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.processResume()
gg.refineNumber("0.5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
revert = gg.getResults(52000, nil, nil, nil, nil, nil, nil, nil, nil)
gg.editAll("10", gg.TYPE_FLOAT)
gg.processResume()
end

function a4()
    gg.setRanges(gg.REGION_C_ALLOC)
    gg.searchNumber("R_R({800C90C0rD;7A01A801rD;58011B01rD;39016001rD;7101A901rD;FC013402rD;7402D902rD;19032203rD;5103D003rD;46044E04rD;FB03DC03rD;38046804rD;CB030503rD;FF024003rD;D102FF01rD;AC01C901rD;C0016901rD;E8006200rD;F6FF7EFFrD;B4FEC4FDrD:4089})", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.refineNumber("R_R({8})", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(73)
    gg.editAll("R_R({192,158,121})", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.searchNumber("R_R({1,6,7,8,9,0,0,6,6,7,7,10,7,777,10})", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.refineNumber("R_R({61})", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(40)
    gg.editAll("R_R({192,158,121})", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.setRanges(32)
    gg.searchNumber("R_R({83,65,103,40,11,249,31,224,203,177,215,152,126,127,143,80,52,36,71,8,236,220,255,192,164,152,183,120,94,94,111,47,29,9})", 1, false, 536870912, 0, -1)
    gg.refineNumber("R_R({83,65,103,40,11,249,31,224,203,177,215,152,126,127,143,79,61,37})", 1, false, 536870912, 0, -1)
    gg.getResults(10000)
    gg.editAll("R_R({83,65,103,40,11,249,31,224,199,185,215,152,127,108,143})", 1)
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,98,134,182,25,26,62,110,209,210,246,42,137,138,176,240,65,65,111,155})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.refineNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,97,143,183})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(10000)
    gg.editAll("R_R({165,211,57,58,93,139,241,242,25,75,169,170,209,254,97})", gg.TYPE_BYTE)
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,98,141,184,25,26,68,125,209,210,11,41,137,138,176,240,65,65,111,155})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.refineNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,97,143,183})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(10000)
    gg.editAll("R_R({165,211,57,58,93,139,241,242,25,75,169,170,209,254,97})", gg.TYPE_BYTE)
    gg.clearResults()
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,98,134,182,25,26,62,110,209,210,246,42,137,138,176,240,65,65,111,155})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.refineNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,97,143,183})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(10000)
    gg.editAll("R_R({165,211,57,58,93,139,241,242,25,75,169,170,209,254,97})", gg.TYPE_BYTE)
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,98,141,184,25,26,68,125,209,210,11,41,137,138,176,240,65,65,111,155})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.refineNumber("R_R({165,211,57,58,93,139,241,242,29,67,169,170,208,17,97,97,143,183})", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(10000)
    gg.editAll("R_R({165,211,57,58,93,139,241,242,25,75,169,170,209,254,97})", gg.TYPE_BYTE)
    gg.clearResults()
    gg.setRanges(gg.REGION_CODE_APP)
    gg.searchNumber("-1,042,808,832;-382,908,176;-494,030,832;-498,216,944;-509,591,552;-442,564,368::21", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
    gg.searchNumber("-1,042,808,832", gg.TYPE_DWORD, false, gg.SIGN_EQUAL, 0, -1)
    gg.getResults(1)
    gg.editAll("1,120,403,456", gg.TYPE_FLOAT)
    gg.clearResults()
    gg.clearResults()
    STM1 = gg.getListItems()
    gg.removeListItems(STM1)
    gg.clearResults()
    gg.toast("🛡️ANTIBAN FULL🛡️")
end

function a5()
gg.clearResults()
gg.setRanges(gg.REGION_CODE_APP)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("127B;69B;76B;70B;1B;1B;1B;0B::8", gg.TYPE_QWORD, nil, nil, nil, nil)
gg.getResults(0)
gg.refineNumber("72", gg.TYPE_QWORD)
gg.getResults("4")
gg.editAll("70", gg.TYPE_QWORD)
gg.setVisible(false)
gg.getResults(1)
gg.searchNumber("-1.1888024e-10F;-0.00883197878F;-9,004,122,112.0F;4.8888483e24F;-0.0079164654F;1.0865689e-19F;1.0879452e-19F;4.1778991e34F:29", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(0)
gg.refineNumber("-1.1888024e-10;-0.00883197878", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
gg.getResults(100)
gg.editAll("120", gg.TYPE_FLOAT)
gg.clearResults()
gg.toast("ON")
end

function a6()
gg.setRanges(32)
    gg.searchNumber("0.01748251915", 16, false, 536870912, 0, -1)
    gg.getResults(999)
    gg.editAll("-2.2958874e-41", 16)
    gg.clearResults()
    gg.setRanges(32)
    gg.searchNumber("1016018816", 4, false, 536870912, 0, -5)
    gg.getResults(500)
    gg.editAll("0006018816", 4)
    gg.clearResults()
end

function speedplayer()
menua = gg.multiChoice({
"SPEED PLAYER 20X",
"SPEED PLAYER 30X",
"SPEED PLAYER 50X",
"SPEED PLAYER 100X",
"◀ VOLTAR"},nil,"▶ESCOLHA SEU SPEED")
if menua == nil then else
if menua [1] ==true then speed20x() end
if menua [2] ==true then speed30x() end
if menua [3] ==true then speed50x() end
if menua [4] ==true then speed100x() end
if menua [5] ==true then Main() end
end
XGCK= -1
end




function speed20x()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2.80259693e-44F;1.20000004768F;0.18000000715F;1.40129846e-45F", 16)
gg.refineNumber("1.20000004768", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("6.70", 16)
gg.clearResults(gg.getResultsCount())
gg.toast("SPEED PLAYER 20X ATIVADO 🏃‍♂️")
end


function speed30x()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2.80259693e-44F;1.20000004768F;0.18000000715F;1.40129846e-45F", 16)
gg.refineNumber("1.20000004768", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("3.900", 16)
gg.clearResults(gg.getResultsCount())
gg.toast("SPEED PLAYER 30X ATIVADO 🏃‍♂️")
end

function speed50x()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2.80259693e-44F;1.20000004768F;0.18000000715F;1.40129846e-45F", 16)
gg.refineNumber("1.20000004768", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("10.80", 16)
gg.clearResults(gg.getResultsCount())
gg.toast("SPEED PLAYER 50X ATIVADO 🏃‍♂️")
end

function speed100x()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("2.80259693e-44F;1.20000004768F;0.18000000715F;1.40129846e-45F", 16)
gg.refineNumber("1.20000004768", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("9.909", 16)
gg.clearResults(gg.getResultsCount())
gg.toast("SPEED PLAYER 100X ATIVADO 🏃‍♂️")
end




function antenas()
menua = gg.multiChoice({
"📡 ANTENA CORPO",
"📡 ANTENA CABEÇA FINA",
"📡 ANTENA HOMBRO",
"📡 ANTENA BRAÇO",
"💡 ANTENA LASER ROXA",
"◀ VOLTAR"},nil,"▶ESCOLHA SUA ANTENA FAVORITA")
if menua == nil then else
if menua [1] ==true then antena() end
if menua [2] ==true then antenaf() end
if menua [3] ==true then antenah() end
if menua [4] ==true then antenab() end
if menua [5] ==true then item() end
if menua [6] ==true then Main() end
end
XGCK= -1
end

antCorpo   = off

function antena()
  if antCorpo == off then
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("QDB0A72BE1CFC2FB500000000", 1)
    gg.refineNumber("Q00000000", 1)
    gg.getResults(gg.getResultsCount())
    gg.editAll("Q33F39543", 1)
    gg.clearResults()
    gg.searchNumber("QF36D9BBE2B0562B500000000", 1)
    gg.refineNumber("Q00000000", 1)
    gg.getResults(gg.getResultsCount())
    gg.editAll("Q33F39543", 1)
    gg.clearResults()
    antCorpo = on
    gg.toast("📡 ANTENA CORPO ATIVADA COM SUCESSO")
  elseif antCorpo == on then
    gg.setRanges(gg.REGION_ANONYMOUS)
    gg.searchNumber("Q33F39543", 1)
    gg.getResults(gg.getResultsCount())
    gg.editAll("Q00000000", 1)
    gg.clearResults()
    antCorpo = off
    gg.toast("📡 ANTENA CORPO DESATIVADA COM SUCESSO")
  end
end

function antenaf()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";賰㎙ 㾀", gg.TYPE_WORD)
gg.getResults(gg.getResultsCount())
gg.editAll(";賰㎙䀀䖜", gg.TYPE_WORD)
gg.clearResults(gg.getResultsCount())
gg.searchNumber(";䃬㓓 㾀", gg.TYPE_WORD)
gg.getResults(gg.getResultsCount())
gg.editAll(";䃬㓓䀀䖜", gg.TYPE_WORD)
gg.clearResults(gg.getResultsCount())
end

function antenah()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";㾆뼼 㾀", gg.TYPE_WORD)
gg.getResults(gg.getResultsCount())
gg.editAll(";㾆뼼 䎖", gg.TYPE_WORD)
gg.clearResults(gg.getResultsCount())
gg.searchNumber(";폓뽄 㾀", gg.TYPE_WORD)
gg.getResults(gg.getResultsCount())
gg.editAll(";폓뽄 䎖", gg.TYPE_WORD)
gg.clearResults(gg.getResultsCount())
end

function antenab()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber(";Ꮊ뼐 㾀", gg.TYPE_WORD)
gg.getResults(gg.getResultsCount())
gg.editAll(";Ꮊ뼐 䎖", gg.TYPE_WORD)
gg.clearResults(gg.getResultsCount())
gg.searchNumber(";豫뼆 㾀", gg.TYPE_WORD)
gg.getResults(gg.getResultsCount())
gg.editAll(";豫뼆 䎖", gg.TYPE_WORD)
gg.clearResults(gg.getResultsCount())
end

function item()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("h 69 00 6E 00 67 00 61 00 6D 00 65 00 2F 00 70 00 69 00 63 00 6B 00 75 00 70 00 2F 00 63 00 61 00 6E 00 64 00 79 00 2F 00 6F 00 62 00 33 00 31 00 2F 00 69 00 6E 00 67 00 61 00 6D 00 65 00 74 00 6F 00 6B 00 65 00 6E 00", gg.TYPE_BYTE)
gg.getResults(gg.getResultsCount()) --ingame/pickup/candy/ob31/ingametoken
gg.editAll("h 65 00 66 00 66 00 65 00 63 00 74 00 73 00 2F 00 76 00 66 00 78 00 5F 00 69 00 6E 00 67 00 61 00 6D 00 65 00 5F 00 6C 00 61 00 73 00 65 00 72 00", gg.TYPE_BYTE)
gg.clearResults(gg.getResultsCount())
end

sp = "off" 

function speedhk() 
    if sp == "off" then 
        gg.setRanges(gg.REGION_CODE_APP) 
        gg.searchNumber("0.14177720249", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1) 
        gg.getResults(10) 
        gg.editAll("0.18999999762", gg.TYPE_FLOAT) 
        gg.clearResults() 
        sp = "on" -- Muda para "on"

    elseif sp == "on" then 
        gg.setRanges(gg.REGION_CODE_APP) -- Garante que está na região certa antes de buscar
        gg.searchNumber("0.18999999762", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1) 
        gg.getResults(10) 
        gg.editAll("0.14177720249", gg.TYPE_FLOAT) 
        gg.clearResults() 
        sp = "off" -- Muda de volta para "off"
        
    end 
end



function reg()
menureg = gg.choice({
"🔥 REGEDIT HS 50% #1",
"🔥 REGEDIT HS 60% #2",
"🔥 REGEDIT RAGE HS 80% #1",
"🔥 REGEDIT RAGE HS 90% #2",
"◀ VOLTAR"},nil,"▶ ESCOLHA SUA REGEDIT FAVORITA")
if menureg == 1 then v1() end
if menureg == 2 then v2() end
if menureg == 3 then v3() end
if menureg == 4 then v4() end
if menureg == 5 then Main() end
XGCK= -1
end

function v1()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("15.0;35.0;10.0;20.0::13", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("20;40;35;45", 16)
gg.clearResults(gg.getResultsCount())
end

function v2()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("15.0;35.0;10.0;20.0::13", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("30;50;40;60", 16)
gg.clearResults(gg.getResultsCount())

end

function v3()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("15.0;35.0;10.0;20.0::13", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("25;45;60;80", 16)
gg.clearResults(gg.getResultsCount())

end

function v4()
gg.setRanges(gg.REGION_ANONYMOUS)
gg.searchNumber("15.0;35.0;10.0;20.0::13", 16)
gg.getResults(gg.getResultsCount())
gg.editAll("20;40;55;50", 16)
gg.clearResults(gg.getResultsCount())

end


function menuaimbot()
menua = gg.multiChoice({
"AIMBOT BRAÇO BUGADO",
"◀ VOLTAR"},nil,"▶MENU AIMBOT")
if menua == nil then else
if menua [1] ==true then nightmode() end
if menua [2] ==true then Main() end
end
XGCK= -1
end

  uc = off
  function nightmode()
    if uc == off then
      gg.clearResults()
      gg.clearResults()
      gg.setRanges(gg.REGION_ANONYMOUS)
      gg.searchNumber("96,688,289", gg.TYPE_DWORD)
      gg.getResults("220")
      gg.editAll("2018908708", gg.TYPE_DWORD)
      gg.clearResults()
      gg.clearResults()
      
      uc = on
    elseif uc == on then
      gg.clearResults()
      gg.setRanges(gg.REGION_ANONYMOUS)
      gg.searchNumber("2018908708", gg.TYPE_DWORD)
      gg.getResults("220")
      gg.editAll("96,688,289", gg.TYPE_DWORD)
      gg.clearResults()
      
      uc = off
    end
  end
  
  
  nm = off
  function nightmode222()
    if nm == off then
      gg.clearResults()
      gg.setRanges(gg.REGION_ANONYMOUS)
      gg.searchNumber("75D;5F;4F::30", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
      gg.refineNumber("4", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
      gg.getResults(12)
      gg.editAll("3", gg.TYPE_FLOAT)
      gg.clearResults()
      
      nm = on
    elseif nm == on then
      gg.clearResults()
      gg.setRanges(gg.REGION_ANONYMOUS)
      gg.searchNumber("75D;5F;3F::30", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
      gg.refineNumber("3", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
      gg.getResults(12)
      gg.editAll("4", gg.TYPE_FLOAT)
      gg.clearResults()
      
      nm = off
    end
  end
  
  
  
  sf = off
  function savefast()
    if sf == off then
      gg.setRanges(gg.REGION_CODE_APP)
      gg.searchNumber("3.14159274101", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
      gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
      gg.editAll("5", gg.TYPE_FLOAT)
      gg.clearResults()
      
      sf = on
    elseif sf == on then
      gg.setRanges(gg.REGION_CODE_APP)
      gg.searchNumber("5", gg.TYPE_FLOAT, false, gg.SIGN_EQUAL, 0, -1)
      gg.getResults(1000, nil, nil, nil, nil, nil, nil, nil, nil)
      gg.editAll("3.14159274101", gg.TYPE_FLOAT)
      gg.clearResults()
      
      sf = off
    end
  end




function white()
gg["setRanges"](5)
gg["searchNumber"]("0000000ch;00000031h;000000BEh;40800000h::29", 4, false, 536870912, 0, -1)
gg["searchNumber"]("40800000h", 4, false, 536870912, 0, -1)
gg["getResults"](400)
gg["editAll"]("44613f36h", 4)
gg["clearResults"]()
gg["toast"]("Boneco Branco Ativado⚪️")
end


function a9()
gg.alert("💎 Script BY @LEO MODZ 💎")
gg.alert("Inscreva-se já♥️")
gg.alert("Quem assistir sem se inscrever vai se dar mal🗿")
print("☆┌─┐ .─┐☆")
print("│▒│ /▒/")
print("│▒│/▒/ ")
print("│▒/▒/─┬─┐")
print("│▒│▒|▒│▒│ ")
print("┌┴─┴─┐-┘─┘")
print("│▒┌──┘▒▒▒│ ")
print("└┐▒▒▒▒▒▒┌┘")
print("└┐▒▒▒▒┌┘")
print("Lembre-se de se inscrever no canal para me ajudar")
print("\nEu amo vocês💎")
print("\n❤️Script Antiban❤️")
print("\n🇧🇷Deixar o Like e se Inscrever no Canal??🇳")
os.exit()
end



-- ============================================
-- LOG DE ERROS DE INICIALIZAÇÃO
-- ============================================
local function write_log(err)
    local message = tostring(err or "ERRO DESCONHECIDO")
    pcall(function()
        local file = io.open("/sdcard/LM_TEAM_ERROR.log", "a")
        if file then
            file:write(os.date("[%Y-%m-%d %H:%M:%S] "), message, "\\n")
            file:close()
        end
    end)
    pcall(function()
        gg.toast("ERRO NO MENU: " .. message)
    end)
end

-- ============================================
-- 12. TRATAMENTO DE ERROS E EXECUÇÃO FINAL
-- ============================================
local function protected_main()
    local status, err = pcall(function()
        invoke() 
    end)
    
    if not status then
        write_log(err)
        pcall(function() gg.setVisible(true) end)
        
        activity.runOnUiThread(luajava.createProxy("java.lang.Runnable", {
            run = function()
                pcall(function()
                    if view then window.removeView(view) end
                    Lock.unUi()
                end)
            end
        }))
        os.exit()
    end
end

Lock.Ui(protected_main)
