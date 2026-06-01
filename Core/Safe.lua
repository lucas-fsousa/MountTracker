-- Core/Safe.lua
-- Camada de seguranca: blinda os pontos de entrada do addon contra erros Lua
-- (sem erro no meio da tela do usuario) e lida com "Secret Values" do Midnight 12.0.
--
-- Filosofia: NUNCA desativamos o frame de erro global do Blizzard (isso afetaria
-- outros addons). Em vez disso, todo handler nosso (evento, slash, clique de botao)
-- roda dentro de pcall. Se algo falhar, o erro NAO propaga p/ o handler global e o
-- usuario ve apenas uma mensagem curta no chat.

local ADDON, ns = ...

local Safe = {}
ns.Safe = Safe

-- issecretvalue existe no Midnight 12.0+. Em versoes antigas e nil.
local _issecret = _G.issecretvalue

-- True se o valor for um "Secret Value" (so no Midnight). Falso em clientes antigos.
function Safe.IsSecret(v)
    if not _issecret then return false end
    local ok, res = pcall(_issecret, v)
    return ok and res == true
end

-- Normaliza um valor possivelmente secreto.
-- Retorna (valor, isSecret): se for secreto, devolve `fallback` e isSecret=true.
function Safe.Value(v, fallback)
    if Safe.IsSecret(v) then return fallback, true end
    return v, false
end

-- Executa fn(...) protegido. Em erro: mostra msg discreta no chat e NAO propaga.
-- `ctx` = descricao curta da acao (entra na mensagem ao usuario).
-- Retorna ate 5 valores de retorno de fn (suficiente p/ nossos usos), ou nil em erro.
function Safe.Call(ctx, fn, ...)
    local ok, a, b, c, d, e = pcall(fn, ...)
    if ok then
        return a, b, c, d, e
    end
    ns.Print("|cffff6060couldn't " .. tostring(ctx) .. ".|r")
    ns._lastError = tostring(a)
    if ns.DEBUG then
        ns.Print("|cff888888debug:|r " .. tostring(a))
    end
    return nil
end

-- Envolve uma funcao, devolvendo uma versao "blindada" (ideal p/ OnClick/OnEvent).
function Safe.Wrap(ctx, fn)
    return function(...)
        return Safe.Call(ctx, fn, ...)
    end
end
