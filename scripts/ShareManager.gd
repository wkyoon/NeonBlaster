extends Node
## ShareManager (Autoload)
## 단어 카드를 이미지로 만들어 소셜에 공유한다.
##
## ⚠️ **`Share` 를 식별자로 직접 쓰면 안 된다.** 플러그인의 `class_name` 이라
##    애드온을 지운 환경에서는 **이 스크립트가 컴파일에 실패하고 오토로드가 통째로 죽는다**
##    (HUD 에서 같은 사고를 이미 겪었다). 스크립트를 **경로로 로드**해서 쓴다.
## ⚠️ stub 판정은 애드온 존재가 아니라 **안드로이드 싱글톤 유무**로 한다.
##    플러그인은 싱글톤이 없으면 호출을 조용히 무시해서, 데스크톱에서는 아무 일도 일어나지 않는다.
##    데스크톱에서는 대신 카드를 `user://` 에 저장하고 경로를 알려 준다(확인용).

signal share_finished(ok: bool, message: String)

const SHARE_SCRIPT := "res://addons/SharePlugin/Share.gd"
const ANDROID_SINGLETON := "SharePlugin"
## 데스크톱에서 확인할 때 카드를 저장하는 곳.
const PREVIEW_PATH := "user://share_card.png"

var _share: Object = null
var _is_stub: bool = true


func _ready() -> void:
	if not ResourceLoader.exists(SHARE_SCRIPT) or not Engine.has_singleton(ANDROID_SINGLETON):
		print("[ShareManager] 공유 플러그인 없음. stub 모드(카드를 user:// 에 저장).")
		return
	var script: Script = load(SHARE_SCRIPT)
	_share = script.new()
	if _share == null:
		return
	_is_stub = false
	if _share is Node:
		add_child(_share)
	if _share.has_signal("share_completed"):
		_share.connect("share_completed", func(_a): share_finished.emit(true, ""))
	if _share.has_signal("share_failed"):
		_share.connect("share_failed", func(msg): share_finished.emit(false, String(msg)))
	if _share.has_signal("share_canceled"):
		_share.connect("share_canceled", func(): share_finished.emit(false, "CANCELED"))
	print("[ShareManager] 공유 플러그인 초기화(SharePlugin 6.0).")


## 단어 카드를 만들어 공유한다.
## ⚠️ `render_card` 는 한 프레임을 기다리는 코루틴이라 **await 가 필요**하다.
##    호출부도 `await ShareManager.share_word(...)` 로 받아야 버튼 상태가 제때 돌아온다.
func share_word(word: String) -> void:
	var tex: Texture2D = await render_card(word)
	if tex == null:
		share_finished.emit(false, "RENDER FAILED")
		return
	# 이미지와 함께 보낼 글. 예문을 그대로 넣어 말풍선 내용이 텍스트로도 전달된다.
	var phrase := WordDictionary.get_phrase(word)
	var body := "%s — %s" % [word.to_upper(), phrase] if phrase != "" else word.to_upper()

	if _is_stub:
		var img := tex.get_image()
		img.save_png(PREVIEW_PATH)
		print("[ShareManager] stub 공유 — 카드를 저장했습니다: ", PREVIEW_PATH)
		share_finished.emit(true, PREVIEW_PATH)
		return
	if _share.has_method("share_texture"):
		_share.share_texture(tex, "WORD BLASTER", word.to_upper(), body)
	else:
		share_finished.emit(false, "PLUGIN API MISMATCH")


## 카드를 한 프레임 렌더해 텍스처로 돌려준다.
## ⚠️ `SubViewport` 는 **한 프레임을 기다려야** 내용이 채워진다. 바로 읽으면 빈 이미지가 나온다.
func render_card(word: String) -> Texture2D:
	var vp := SubViewport.new()
	vp.size = Vector2i(int(ShareCard.SIZE), int(ShareCard.SIZE))
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(vp)

	var card := ShareCard.new()
	card.setup(word)
	vp.add_child(card)

	# 한 프레임 그린 뒤 읽는다.
	await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	vp.queue_free()
	return ImageTexture.create_from_image(img)
