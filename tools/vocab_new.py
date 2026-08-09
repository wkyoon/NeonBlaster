#!/usr/bin/env python3
"""추가할 테마와 단어 데이터. `gen_vocab.py` 가 이걸 읽어 GDScript 를 갱신한다.

형식: (단어, 이모지, 한국어 설명, 영어 설명, 예문)

⚠️ 규칙
  1. `basic` 8개 / `advanced` 4개, 각각 **글자 수 오름차순**
  2. `advanced` 의 첫 단어는 `basic` 의 마지막보다 짧으면 안 된다(층 경계 역전 방지)
  3. 단어는 테마 사이에 **중복되면 안 된다**(도감 수집이 한 번만 되므로)
  4. 예문은 그 단어를 실제로 쓰는 짧은 문장 — 음성으로 읽어 준다
"""

THEMES = []


def theme(tid, ko, en, motif, bg, accent, particle, basic, advanced):
	THEMES.append({
		"id": tid, "name_ko": ko, "name_en": en, "motif": motif,
		"bg": bg, "accent": accent, "particle": particle,
		"basic": basic, "advanced": advanced,
	})


theme("FOOD", "음식", "FOOD", "BLOB", (0.11, 0.07, 0.04), (1.0, 0.65, 0.3), (1.0, 0.8, 0.45),
[
	("EGG", "🥚", "달걀. 껍질 안에 노른자가 있어요.", "A round food with a shell and a yellow center.", "I ate an egg for breakfast."),
	("RICE", "🍚", "쌀밥. 밥그릇에 담아 먹어요.", "Small white grains cooked and eaten warm.", "She eats rice every day."),
	("MEAT", "🍖", "고기. 구워서 먹는 음식이에요.", "Food that comes from animals.", "The meat is on the grill."),
	("SOUP", "🍲", "국. 따뜻하게 떠먹는 음식이에요.", "A warm liquid food you eat with a spoon.", "The soup is very hot."),
	("BREAD", "🍞", "빵. 밀가루로 구운 음식이에요.", "A baked food made from flour.", "He cuts the bread slowly."),
	("PIZZA", "🍕", "피자. 둥글고 치즈가 올라가요.", "A round flat food covered with cheese.", "We share a big pizza."),
	("SALAD", "🥗", "샐러드. 채소를 섞어 먹어요.", "A cold mix of fresh vegetables.", "The salad tastes fresh."),
	("CHEESE", "🧀", "치즈. 우유로 만든 노란 음식이에요.", "A yellow food made from milk.", "Cheese melts on the bread."),
],
[
	("NOODLE", "🍜", "국수. 길고 가는 면이에요.", "A long thin strip of food made from flour.", "The noodle is long and soft."),
	("BUTTER", "🧈", "버터. 빵에 발라 먹어요.", "A soft yellow food you spread on bread.", "Butter melts on warm bread."),
	("SANDWICH", "🥪", "샌드위치. 빵 사이에 재료를 넣어요.", "Food put between two slices of bread.", "He makes a big sandwich."),
	("CHOCOLATE", "🍫", "초콜릿. 달고 갈색인 간식이에요.", "A sweet brown treat that melts easily.", "The chocolate melts in my hand."),
])

theme("FRUIT", "과일", "FRUIT", "LEAF", (0.06, 0.10, 0.05), (1.0, 0.5, 0.5), (1.0, 0.8, 0.4),
[
	("FIG", "🫒", "무화과. 작고 달콤한 과일이에요.", "A small sweet fruit with many seeds.", "The fig is soft and sweet."),
	("KIWI", "🥝", "키위. 속이 초록색인 과일이에요.", "A small fruit that is green inside.", "The kiwi is green inside."),
	("PEAR", "🍐", "배. 아삭하고 물이 많아요.", "A sweet juicy fruit shaped like a bell.", "This pear is very juicy."),
	("PLUM", "🍑", "자두. 작고 새콤한 과일이에요.", "A small round fruit with a stone inside.", "The plum tastes a bit sour."),
	("APPLE", "🍎", "사과. 빨갛고 아삭한 과일이에요.", "A round red fruit that is crisp to bite.", "She bites a red apple."),
	("GRAPE", "🍇", "포도. 송이로 달린 작은 열매예요.", "A small round fruit that grows in bunches.", "The grape is small and sweet."),
	("LEMON", "🍋", "레몬. 아주 신 노란 과일이에요.", "A yellow fruit with a very sour taste.", "The lemon is very sour."),
	("PEACH", "🍑", "복숭아. 겉에 솜털이 있어요.", "A soft fruit with fuzzy skin.", "The peach smells sweet."),
],
[
	("BANANA", "🍌", "바나나. 길고 노란 과일이에요.", "A long yellow fruit you peel.", "He peels a yellow banana."),
	("CHERRY", "🍒", "체리. 작고 빨간 열매예요.", "A small red fruit with a stone inside.", "A cherry hangs on the tree."),
	("AVOCADO", "🥑", "아보카도. 초록색이고 부드러워요.", "A green fruit that is soft and creamy.", "The avocado is soft inside."),
	("PINEAPPLE", "🍍", "파인애플. 껍질이 거칠어요.", "A large fruit with rough skin and sweet flesh.", "The pineapple has rough skin."),
])

theme("DRINK", "음료", "DRINKS", "BLOB", (0.04, 0.08, 0.11), (0.4, 0.85, 1.0), (0.6, 0.95, 1.0),
[
	("TEA", "🍵", "차. 따뜻하게 우려 마셔요.", "A hot drink made from leaves in water.", "She drinks hot tea."),
	("MILK", "🥛", "우유. 하얗고 고소해요.", "A white drink that comes from cows.", "The milk is cold and white."),
	("SODA", "🥤", "탄산음료. 톡 쏘는 맛이에요.", "A sweet drink with bubbles in it.", "The soda has many bubbles."),
	("WINE", "🍷", "포도주. 포도로 만든 어른 음료예요.", "A drink made from grapes.", "Wine is made from grapes."),
	("JUICE", "🧃", "주스. 과일을 짜서 만들어요.", "A drink squeezed from fruit.", "I drink orange juice."),
	("WATER", "💧", "물. 가장 중요한 음료예요.", "The clear drink our body needs most.", "Please give me some water."),
	("COCOA", "☕", "코코아. 달고 따뜻한 음료예요.", "A sweet warm brown drink.", "The cocoa is warm and sweet."),
	("COFFEE", "☕", "커피. 쓰고 진한 음료예요.", "A dark bitter drink that wakes you up.", "He drinks coffee every morning."),
],
[
	("NECTAR", "🍯", "꽃꿀. 벌이 모으는 달콤한 즙이에요.", "The sweet liquid inside flowers.", "Bees collect sweet nectar."),
	("YOGURT", "🥣", "요구르트. 우유를 발효한 음식이에요.", "A thick food made from sour milk.", "The yogurt tastes sour."),
	("LEMONADE", "🍋", "레모네이드. 레몬으로 만든 음료예요.", "A cold drink made from lemons and sugar.", "We sell cold lemonade."),
	("SMOOTHIE", "🥤", "스무디. 과일을 갈아 만든 음료예요.", "A thick drink made from blended fruit.", "The smoothie is thick and cold."),
])

theme("FAMILY", "가족", "FAMILY", "PULSE", (0.10, 0.05, 0.09), (1.0, 0.55, 0.75), (1.0, 0.75, 0.85),
[
	("MOM", "👩", "엄마. 나를 낳아 주신 분이에요.", "The woman who is your parent.", "My mom reads me a book."),
	("DAD", "👨", "아빠. 나를 키워 주신 분이에요.", "The man who is your parent.", "My dad drives the car."),
	("SON", "👦", "아들. 부모의 남자 아이예요.", "A boy child of a parent.", "Their son is very tall."),
	("AUNT", "👩‍🦰", "이모나 고모. 부모의 자매예요.", "The sister of your mother or father.", "My aunt lives near us."),
	("BABY", "👶", "아기. 아주 어린 아이예요.", "A very young child.", "The baby is sleeping now."),
	("UNCLE", "🧔", "삼촌. 부모의 형제예요.", "The brother of your mother or father.", "My uncle tells funny stories."),
	("SISTER", "👧", "여자 형제예요.", "A girl with the same parents as you.", "My sister plays the piano."),
	("FATHER", "👨‍🦱", "아버지. 아빠를 부르는 말이에요.", "Another word for your dad.", "His father works at night."),
],
[
	("COUSIN", "🧑", "사촌. 삼촌의 아이예요.", "The child of your aunt or uncle.", "My cousin visits every summer."),
	("MOTHER", "👩‍🦳", "어머니. 엄마를 부르는 말이에요.", "Another word for your mom.", "Her mother bakes fresh bread."),
	("BROTHER", "👦", "남자 형제예요.", "A boy with the same parents as you.", "My brother rides a bike."),
	("DAUGHTER", "👧", "딸. 부모의 여자 아이예요.", "A girl child of a parent.", "Their daughter sings very well."),
])

theme("HOUSE", "집", "HOUSE", "GEAR", (0.09, 0.07, 0.05), (1.0, 0.8, 0.45), (0.95, 0.85, 0.6),
[
	("BED", "🛏️", "침대. 잠을 자는 곳이에요.", "The furniture you sleep on.", "I sleep in a soft bed."),
	("CUP", "🥤", "컵. 마실 것을 담아요.", "A small container for drinking.", "The cup is on the table."),
	("DOOR", "🚪", "문. 방을 드나드는 곳이에요.", "The part of a wall you open to go through.", "Please close the door."),
	("LAMP", "💡", "등. 어두울 때 켜요.", "A light you turn on in a dark room.", "The lamp lights the room."),
	("SOFA", "🛋️", "소파. 여럿이 앉는 의자예요.", "A long soft seat for a few people.", "We sit on the sofa."),
	("CHAIR", "🪑", "의자. 한 사람이 앉아요.", "A seat for one person.", "He pulls out a chair."),
	("TABLE", "🍽️", "탁자. 물건을 올려 두어요.", "A flat surface with legs to put things on.", "Books are on the table."),
	("WINDOW", "🪟", "창문. 밖을 볼 수 있어요.", "An opening in a wall with glass.", "Open the window for air."),
],
[
	("MIRROR", "🪞", "거울. 내 모습을 비춰요.", "A glass that shows your own face.", "She looks in the mirror."),
	("PILLOW", "🛏️", "베개. 머리를 받쳐요.", "A soft bag you rest your head on.", "The pillow is very soft."),
	("BLANKET", "🧣", "담요. 몸을 덮어 따뜻하게 해요.", "A warm cover you use in bed.", "He pulls up the blanket."),
	("FURNITURE", "🪑", "가구. 집 안의 큰 물건들이에요.", "The large things inside a room.", "The furniture is made of wood."),
])

theme("SCHOOL", "학교", "SCHOOL", "STAR", (0.05, 0.06, 0.12), (0.55, 0.75, 1.0), (0.7, 0.85, 1.0),
[
	("PEN", "🖊️", "펜. 잉크로 글씨를 써요.", "A tool that writes with ink.", "I write with a blue pen."),
	("BOOK", "📕", "책. 글이 담긴 물건이에요.", "Pages with words bound together.", "She reads a thick book."),
	("DESK", "🪑", "책상. 앉아서 공부하는 곳이에요.", "A table you study at.", "My desk is near the window."),
	("NOTE", "📝", "쪽지. 짧게 적어 두는 글이에요.", "A short piece of writing.", "He writes a quick note."),
	("CHALK", "🖍️", "분필. 칠판에 쓰는 도구예요.", "A white stick for writing on a board.", "The chalk is white and dusty."),
	("PAPER", "📄", "종이. 글을 쓰는 얇은 것이에요.", "A thin flat sheet you write on.", "Write it on this paper."),
	("RULER", "📏", "자. 길이를 재는 도구예요.", "A tool for measuring length.", "Use a ruler to draw lines."),
	("PENCIL", "✏️", "연필. 지울 수 있는 필기구예요.", "A writing tool you can erase.", "Sharpen your pencil first."),
],
[
	("ERASER", "🧽", "지우개. 쓴 것을 지워요.", "A tool that removes pencil marks.", "The eraser removes the mistake."),
	("TEACHER", "👩‍🏫", "선생님. 가르쳐 주는 분이에요.", "A person who teaches students.", "Our teacher explains the lesson."),
	("STUDENT", "🧑‍🎓", "학생. 배우는 사람이에요.", "A person who learns at school.", "Every student has a book."),
	("CLASSROOM", "🏫", "교실. 수업을 하는 방이에요.", "The room where lessons happen.", "The classroom is very quiet."),
])

theme("CLOTHES", "옷", "CLOTHES", "BLOB", (0.10, 0.05, 0.11), (1.0, 0.6, 0.95), (1.0, 0.8, 1.0),
[
	("CAP", "🧢", "모자. 챙이 달린 모자예요.", "A soft hat with a curved front.", "He wears a blue cap."),
	("HAT", "👒", "모자. 머리에 쓰는 것이에요.", "Something you wear on your head.", "Her hat blocks the sun."),
	("COAT", "🧥", "외투. 추울 때 겉에 입어요.", "A warm piece of clothing for outside.", "Put on your warm coat."),
	("SHOE", "👟", "신발. 발에 신어요.", "Something you wear on your foot.", "My shoe is too small."),
	("SOCK", "🧦", "양말. 신발 안에 신어요.", "Soft clothing for your foot.", "One sock is missing."),
	("DRESS", "👗", "원피스. 한 벌로 된 옷이에요.", "A one-piece garment worn by girls.", "She wears a red dress."),
	("SHIRT", "👕", "셔츠. 윗옷이에요.", "Clothing for the top of your body.", "His shirt has blue stripes."),
	("SKIRT", "👚", "치마. 아래에 입는 옷이에요.", "Clothing that hangs from the waist.", "The skirt is very long."),
],
[
	("JACKET", "🧥", "재킷. 짧은 겉옷이에요.", "A short coat for cool weather.", "He zips up his jacket."),
	("SWEATER", "🧶", "스웨터. 털실로 짠 옷이에요.", "A warm top made of wool.", "The sweater keeps me warm."),
	("UNIFORM", "👔", "교복. 같은 모양으로 입는 옷이에요.", "Clothing everyone in a group wears.", "Students wear the same uniform."),
	("TROUSERS", "👖", "바지. 다리에 입는 옷이에요.", "Clothing that covers both legs.", "These trousers are too long."),
])

theme("SPORT", "운동", "SPORTS", "PULSE", (0.05, 0.10, 0.07), (0.4, 1.0, 0.6), (0.6, 1.0, 0.7),
[
	("RUN", "🏃", "달리기. 빠르게 뛰는 운동이에요.", "To move fast on your feet.", "They run around the field."),
	("SWIM", "🏊", "수영. 물에서 하는 운동이에요.", "To move through water.", "We swim in the pool."),
	("GOLF", "⛳", "골프. 공을 쳐서 구멍에 넣어요.", "A game of hitting a ball into holes.", "He plays golf on Sunday."),
	("JUMP", "🤸", "점프. 위로 뛰어오르는 거예요.", "To push yourself up into the air.", "She can jump very high."),
	("CLIMB", "🧗", "등반. 위로 올라가는 운동이에요.", "To go up using hands and feet.", "They climb the tall wall."),
	("SKATE", "⛸️", "스케이트. 얼음 위를 달려요.", "To glide on ice or wheels.", "We skate on the frozen lake."),
	("TENNIS", "🎾", "테니스. 라켓으로 공을 쳐요.", "A game played with rackets and a ball.", "They play tennis every week."),
	("SOCCER", "⚽", "축구. 발로 공을 차요.", "A game where you kick a ball into a goal.", "Soccer needs eleven players."),
],
[
	("BOXING", "🥊", "권투. 주먹으로 겨루는 운동이에요.", "A sport of fighting with fists in gloves.", "Boxing needs strong arms."),
	("HOCKEY", "🏒", "하키. 스틱으로 퍽을 쳐요.", "A game played with sticks on ice.", "Hockey is played on ice."),
	("BASEBALL", "⚾", "야구. 방망이로 공을 쳐요.", "A game of hitting a ball with a bat.", "He hits the baseball hard."),
	("BASKETBALL", "🏀", "농구. 공을 골대에 넣어요.", "A game of throwing a ball into a hoop.", "Basketball players are very tall."),
])

theme("MUSIC", "음악", "MUSIC", "PULSE", (0.08, 0.04, 0.12), (0.8, 0.5, 1.0), (0.9, 0.7, 1.0),
[
	("BAND", "🎸", "밴드. 함께 연주하는 무리예요.", "A group that plays music together.", "The band plays on stage."),
	("BEAT", "🥁", "박자. 음악의 규칙적인 소리예요.", "The regular rhythm of music.", "Clap along with the beat."),
	("DRUM", "🥁", "북. 두드려 소리를 내요.", "An instrument you hit to make sound.", "He hits the drum loudly."),
	("HARP", "🎼", "하프. 줄을 뜯는 큰 악기예요.", "A large instrument with many strings.", "The harp sounds very gentle."),
	("FLUTE", "🎶", "플루트. 불어서 소리를 내요.", "A thin instrument you blow into.", "She plays a silver flute."),
	("PIANO", "🎹", "피아노. 건반을 눌러 연주해요.", "An instrument with black and white keys.", "The piano has many keys."),
	("VIOLIN", "🎻", "바이올린. 활로 줄을 켜요.", "A small string instrument played with a bow.", "The violin makes a sweet sound."),
	("GUITAR", "🎸", "기타. 줄을 튕겨 연주해요.", "A string instrument you strum.", "He plays guitar in the park."),
],
[
	("MELODY", "🎵", "선율. 노래의 흐르는 가락이에요.", "The main tune of a song.", "That melody is easy to sing."),
	("TRUMPET", "🎺", "트럼펫. 금관 악기예요.", "A loud brass instrument you blow.", "The trumpet is very loud."),
	("ORCHESTRA", "🎻", "관현악단. 많은 악기가 함께 연주해요.", "A large group of many instruments.", "The orchestra plays together."),
	("SAXOPHONE", "🎷", "색소폰. 굽은 관악기예요.", "A curved brass instrument with keys.", "The saxophone sounds warm."),
])

theme("JOB", "직업", "JOBS", "GEAR", (0.06, 0.07, 0.10), (0.7, 0.85, 1.0), (0.8, 0.9, 1.0),
[
	("CHEF", "👨‍🍳", "요리사. 음식을 만들어요.", "A person who cooks food for others.", "The chef cooks a fine meal."),
	("NURSE", "👩‍⚕️", "간호사. 환자를 돌봐요.", "A person who cares for sick people.", "The nurse checks my arm."),
	("PILOT", "👨‍✈️", "조종사. 비행기를 몰아요.", "A person who flies an airplane.", "The pilot lands the plane."),
	("BAKER", "👩‍🍳", "제빵사. 빵을 구워요.", "A person who bakes bread and cakes.", "The baker makes fresh bread."),
	("ACTOR", "🎭", "배우. 연기를 해요.", "A person who acts in plays or films.", "The actor learns his lines."),
	("DOCTOR", "👨‍⚕️", "의사. 병을 고쳐요.", "A person who treats sick people.", "The doctor helps the patient."),
	("FARMER", "👨‍🌾", "농부. 곡식과 채소를 길러요.", "A person who grows food on land.", "The farmer grows corn."),
	("POLICE", "👮", "경찰. 사람들을 지켜요.", "People who keep others safe.", "The police help lost children."),
],
[
	("ARTIST", "🎨", "화가. 그림을 그려요.", "A person who makes art.", "The artist paints a river."),
	("DENTIST", "🦷", "치과의사. 이를 치료해요.", "A doctor who takes care of teeth.", "The dentist checks my teeth."),
	("ENGINEER", "🔧", "기술자. 기계를 설계하고 고쳐요.", "A person who designs and builds machines.", "The engineer fixes the engine."),
	("SCIENTIST", "🔬", "과학자. 실험하고 연구해요.", "A person who studies how things work.", "The scientist studies the stars."),
])

theme("CITY", "도시", "CITY", "GEAR", (0.07, 0.06, 0.09), (0.6, 0.8, 1.0), (0.75, 0.85, 1.0),
[
	("MAP", "🗺️", "지도. 길을 그린 그림이에요.", "A drawing that shows where places are.", "We look at the map."),
	("BANK", "🏦", "은행. 돈을 맡기는 곳이에요.", "A place where people keep money.", "The bank opens at nine."),
	("PARK", "🏞️", "공원. 나무가 많은 넓은 곳이에요.", "An open green place in a city.", "Children play in the park."),
	("SHOP", "🏪", "가게. 물건을 파는 곳이에요.", "A place where things are sold.", "The shop sells fresh fruit."),
	("HOTEL", "🏨", "호텔. 여행 중에 자는 곳이에요.", "A building where travelers sleep.", "We stay at a small hotel."),
	("TOWER", "🗼", "탑. 아주 높은 건물이에요.", "A very tall narrow building.", "The tower is very tall."),
	("BRIDGE", "🌉", "다리. 강을 건너는 길이에요.", "A road built over water.", "The bridge crosses the river."),
	("MARKET", "🏬", "시장. 여러 가게가 모인 곳이에요.", "A place where many things are sold.", "The market is busy today."),
],
[
	("STATION", "🚉", "역. 기차를 타는 곳이에요.", "A place where trains stop.", "The train leaves the station."),
	("LIBRARY", "📚", "도서관. 책을 빌리는 곳이에요.", "A quiet place full of books.", "The library is very quiet."),
	("HOSPITAL", "🏥", "병원. 아플 때 가는 곳이에요.", "A place where sick people are treated.", "The hospital is near here."),
	("RESTAURANT", "🍽️", "식당. 음식을 사 먹는 곳이에요.", "A place where you buy and eat meals.", "We eat at a new restaurant."),
])

theme("VEHICLE", "탈것", "VEHICLES", "GEAR", (0.05, 0.08, 0.10), (0.5, 0.9, 1.0), (0.7, 0.95, 1.0),
[
	("BUS", "🚌", "버스. 여러 사람이 함께 타요.", "A big road vehicle for many people.", "The bus stops at the corner."),
	("CAR", "🚗", "자동차. 바퀴 네 개로 달려요.", "A road vehicle with four wheels.", "The car turns left."),
	("VAN", "🚐", "밴. 짐과 사람을 함께 실어요.", "A vehicle for carrying people or goods.", "The van carries many boxes."),
	("BIKE", "🚲", "자전거. 발로 굴려서 타요.", "A two-wheeled vehicle you pedal.", "He rides his bike to school."),
	("BOAT", "⛵", "배. 물 위를 다녀요.", "A small vessel that travels on water.", "The boat floats on the lake."),
	("SHIP", "🚢", "배. 바다를 건너는 큰 배예요.", "A large vessel that crosses the sea.", "The ship sails at dawn."),
	("TRAIN", "🚆", "기차. 선로 위를 달려요.", "A long vehicle that runs on rails.", "The train arrives on time."),
	("TRUCK", "🚚", "트럭. 무거운 짐을 실어요.", "A large vehicle that carries heavy loads.", "The truck carries wood."),
],
[
	("SUBWAY", "🚇", "지하철. 땅 밑으로 달려요.", "A train that runs under the ground.", "The subway runs underground."),
	("BICYCLE", "🚴", "자전거. 페달을 밟아 달려요.", "A vehicle with two wheels and pedals.", "She locks her bicycle."),
	("AIRPLANE", "✈️", "비행기. 하늘을 날아요.", "A machine that flies through the sky.", "The airplane flies above clouds."),
	("HELICOPTER", "🚁", "헬리콥터. 날개가 돌며 떠요.", "A flying machine with spinning blades.", "The helicopter lands slowly."),
])

theme("WEATHER", "날씨", "WEATHER", "LEAF", (0.04, 0.08, 0.11), (0.5, 0.9, 1.0), (0.75, 0.95, 1.0),
[
	("FOG", "🌫️", "안개. 앞이 뿌옇게 보여요.", "Thick cloud close to the ground.", "The fog hides the road."),
	("HOT", "🔥", "덥다. 온도가 높아요.", "Having a high temperature.", "Today is very hot."),
	("COLD", "🥶", "춥다. 온도가 낮아요.", "Having a low temperature.", "The wind feels cold."),
	("WARM", "🌤️", "따뜻하다. 기분 좋은 온도예요.", "Pleasantly a little hot.", "The room is warm inside."),
	("WIND", "🌬️", "바람. 공기가 움직이는 거예요.", "Air that moves outside.", "The wind moves the leaves."),
	("CLOUD", "☁️", "구름. 하늘에 떠 있는 물방울이에요.", "A white shape floating in the sky.", "One cloud covers the sun."),
	("FROST", "❄️", "서리. 얇게 언 얼음이에요.", "Thin ice that forms on cold mornings.", "Frost covers the grass."),
	("SHOWER", "🌦️", "소나기. 잠깐 내리는 비예요.", "A short fall of rain.", "A shower passes quickly."),
],
[
	("BREEZE", "🍃", "산들바람. 부드러운 바람이에요.", "A light gentle wind.", "A cool breeze feels nice."),
	("DROUGHT", "🏜️", "가뭄. 비가 오래 안 와요.", "A long time with no rain.", "The drought dries the fields."),
	("TYPHOON", "🌀", "태풍. 아주 센 비바람이에요.", "A very strong storm with heavy rain.", "The typhoon brings heavy rain."),
	("LIGHTNING", "⚡", "번개. 하늘에서 번쩍여요.", "A bright flash of light in a storm.", "Lightning flashes in the sky."),
])

theme("TIME", "시간", "TIME", "STAR", (0.06, 0.05, 0.10), (0.75, 0.75, 1.0), (0.85, 0.85, 1.0),
[
	("DAY", "📅", "하루. 아침부터 밤까지예요.", "The time from morning until night.", "Today is a sunny day."),
	("HOUR", "🕐", "시간. 60분이에요.", "A period of sixty minutes.", "Wait for one hour."),
	("WEEK", "📆", "주. 이레, 일곱 날이에요.", "A period of seven days.", "We meet once a week."),
	("YEAR", "🗓️", "해. 열두 달이에요.", "A period of twelve months.", "A year has four seasons."),
	("MONTH", "📅", "달. 한 해의 열두 부분 중 하나예요.", "One of the twelve parts of a year.", "This month is very busy."),
	("NIGHT", "🌙", "밤. 어두운 시간이에요.", "The dark part of the day.", "The night is quiet."),
	("TODAY", "📌", "오늘. 지금 이 날이에요.", "This present day.", "Today is my birthday."),
	("MINUTE", "⌚", "분. 60초예요.", "A period of sixty seconds.", "Wait just one minute."),
],
[
	("SECOND", "⏳", "초. 가장 짧은 시간 단위예요.", "A very short unit of time.", "It takes only a second."),
	("MORNING", "🌅", "아침. 하루가 시작되는 때예요.", "The early part of the day.", "The morning air is fresh."),
	("EVENING", "🌆", "저녁. 해가 지는 때예요.", "The time when the sun goes down.", "We walk in the evening."),
	("YESTERDAY", "⏪", "어제. 오늘의 하루 전이에요.", "The day before today.", "Yesterday was very cold."),
])

theme("SHAPE", "모양", "SHAPES", "BLOB", (0.05, 0.09, 0.09), (0.4, 1.0, 0.9), (0.6, 1.0, 0.95),
[
	("DOT", "⚫", "점. 아주 작은 동그라미예요.", "A very small round mark.", "Draw a small dot here."),
	("CUBE", "🧊", "정육면체. 여섯 면이 같은 상자예요.", "A box with six equal square sides.", "The cube has six sides."),
	("CONE", "🍦", "원뿔. 위가 뾰족한 모양이에요.", "A shape that is round below and pointed above.", "The cone has a sharp top."),
	("LINE", "➖", "선. 곧게 이어진 자국이에요.", "A long straight mark.", "Draw a straight line."),
	("OVAL", "🥚", "타원. 길쭉한 동그라미예요.", "A shape like a stretched circle.", "An egg is an oval."),
	("CIRCLE", "⭕", "원. 완전히 둥근 모양이에요.", "A perfectly round shape.", "The circle has no corners."),
	("SPIRAL", "🌀", "나선. 빙글빙글 도는 모양이에요.", "A curve that winds around a center.", "The spiral turns inward."),
	("SQUARE", "🟦", "정사각형. 네 변이 같아요.", "A shape with four equal sides.", "A square has four sides."),
],
[
	("SPHERE", "🔮", "구. 공처럼 둥근 입체예요.", "A perfectly round solid like a ball.", "A ball is a sphere."),
	("CYLINDER", "🥫", "원기둥. 캔 같은 모양이에요.", "A solid shaped like a can.", "The can is a cylinder."),
	("TRIANGLE", "🔺", "삼각형. 변이 세 개예요.", "A shape with three sides.", "A triangle has three corners."),
	("RECTANGLE", "🟧", "직사각형. 마주 보는 변이 같아요.", "A shape with four sides and square corners.", "The door is a rectangle."),
])

theme("EMOTION", "감정", "FEELINGS", "PULSE", (0.10, 0.04, 0.08), (1.0, 0.5, 0.7), (1.0, 0.7, 0.85),
[
	("JOY", "😄", "기쁨. 아주 좋은 느낌이에요.", "A feeling of great happiness.", "Her face shows pure joy."),
	("FEAR", "😨", "두려움. 무서운 느낌이에요.", "The feeling of being afraid.", "He hides his fear."),
	("LOVE", "❤️", "사랑. 아끼는 마음이에요.", "A deep warm feeling for someone.", "They share a deep love."),
	("CALM", "😌", "차분함. 마음이 고요해요.", "Feeling quiet and peaceful.", "Stay calm and breathe."),
	("ANGRY", "😠", "화남. 몹시 기분이 나빠요.", "Feeling very upset.", "He looks angry today."),
	("HAPPY", "😊", "행복함. 기분이 좋아요.", "Feeling pleased and glad.", "She feels happy today."),
	("PROUD", "😤", "자랑스러움. 뿌듯한 느낌이에요.", "Feeling glad about something you did.", "I am proud of you."),
	("SCARED", "😱", "겁남. 갑자기 무서워요.", "Suddenly afraid of something.", "The loud noise scared me."),
],
[
	("LONELY", "😔", "외로움. 혼자라 쓸쓸해요.", "Feeling sad because you are alone.", "He feels lonely at night."),
	("NERVOUS", "😰", "긴장됨. 마음이 조마조마해요.", "Feeling worried about what will happen.", "She feels nervous before the test."),
	("EXCITED", "🤩", "신남. 기대가 커요.", "Feeling very eager and happy.", "The kids are excited today."),
	("SURPRISED", "😲", "놀람. 예상 못한 일에 놀라요.", "Feeling shocked by something unexpected.", "We were surprised by the gift."),
])

theme("SEA", "바다", "SEA", "LEAF", (0.03, 0.07, 0.11), (0.35, 0.85, 1.0), (0.6, 0.95, 1.0),
[
	("FIN", "🐟", "지느러미. 물고기의 헤엄 도구예요.", "The part a fish uses to swim.", "The fin cuts the water."),
	("CRAB", "🦀", "게. 옆으로 걷는 바다 동물이에요.", "A sea animal that walks sideways.", "The crab walks sideways."),
	("SEAL", "🦭", "물개. 물에서 헤엄치는 동물이에요.", "A smooth sea animal that swims fast.", "The seal claps its flippers."),
	("WAVE", "🌊", "파도. 바다에서 밀려와요.", "Moving water that rises on the sea.", "A big wave hits the rock."),
	("CORAL", "🪸", "산호. 바다 속 딱딱한 생물이에요.", "A hard sea growth of many colors.", "The coral has bright colors."),
	("SHARK", "🦈", "상어. 이가 날카로운 물고기예요.", "A large fish with sharp teeth.", "The shark swims very fast."),
	("WHALE", "🐋", "고래. 바다에서 가장 큰 동물이에요.", "The biggest animal in the sea.", "The whale sings under water."),
	("SHRIMP", "🦐", "새우. 작고 굽은 바다 생물이에요.", "A small curved sea animal.", "The shrimp is small and pink."),
],
[
	("LOBSTER", "🦞", "바닷가재. 집게가 큰 생물이에요.", "A sea animal with two big claws.", "The lobster has strong claws."),
	("OCTOPUS", "🐙", "문어. 다리가 여덟 개예요.", "A sea animal with eight arms.", "The octopus has eight arms."),
	("SEAWEED", "🌿", "해초. 바다에서 자라는 풀이에요.", "A plant that grows in the sea.", "Seaweed floats near the shore."),
	("JELLYFISH", "🎐", "해파리. 투명하고 말랑해요.", "A soft clear sea animal that stings.", "The jellyfish drifts slowly."),
])

theme("INSECT", "곤충", "INSECTS", "PAW", (0.06, 0.09, 0.04), (0.75, 1.0, 0.4), (0.85, 1.0, 0.6),
[
	("ANT", "🐜", "개미. 줄지어 다니는 작은 곤충이에요.", "A tiny insect that walks in lines.", "An ant carries a crumb."),
	("BEE", "🐝", "벌. 꿀을 모으는 곤충이에요.", "An insect that makes honey.", "The bee visits the flower."),
	("FLY", "🪰", "파리. 윙윙 날아다녀요.", "A small insect that buzzes around.", "A fly lands on the plate."),
	("MOTH", "🦋", "나방. 밤에 불빛으로 모여요.", "An insect that flies toward light at night.", "A moth circles the lamp."),
	("WASP", "🐝", "말벌. 침이 있는 곤충이에요.", "A stinging insect with a thin waist.", "The wasp builds a nest."),
	("BEETLE", "🪲", "딱정벌레. 등껍질이 단단해요.", "An insect with a hard shiny shell.", "The beetle has a hard shell."),
	("SPIDER", "🕷️", "거미. 줄을 쳐서 먹이를 잡아요.", "A small animal that spins webs.", "The spider spins a web."),
	("HORNET", "🐝", "장수말벌. 크고 위험한 벌이에요.", "A large wasp with a painful sting.", "The hornet is very large."),
],
[
	("CRICKET", "🦗", "귀뚜라미. 밤에 소리를 내요.", "An insect that chirps at night.", "A cricket sings at night."),
	("LADYBUG", "🐞", "무당벌레. 점이 있는 빨간 벌레예요.", "A small red beetle with black spots.", "The ladybug has black spots."),
	("DRAGONFLY", "🪰", "잠자리. 날개가 네 장이에요.", "An insect with four clear wings.", "A dragonfly hovers over water."),
	("GRASSHOPPER", "🦗", "메뚜기. 잘 뛰는 곤충이에요.", "An insect that jumps very far.", "The grasshopper jumps away."),
])

theme("PLANT", "식물", "PLANTS", "LEAF", (0.04, 0.10, 0.05), (0.5, 1.0, 0.5), (0.7, 1.0, 0.65),
[
	("OAK", "🌳", "참나무. 크고 단단한 나무예요.", "A large strong tree.", "The oak is very old."),
	("LEAF", "🍃", "잎. 나무에 달린 초록 부분이에요.", "The flat green part of a plant.", "One leaf falls slowly."),
	("PINE", "🌲", "소나무. 잎이 뾰족해요.", "A tree with thin sharp leaves.", "The pine stays green all year."),
	("ROOT", "🌱", "뿌리. 땅 속에 있는 부분이에요.", "The part of a plant under the ground.", "The root goes deep down."),
	("SEED", "🌰", "씨. 새 식물이 되는 알갱이예요.", "A small thing that grows into a plant.", "Plant the seed in soil."),
	("GRASS", "🌿", "풀. 땅을 덮는 초록 식물이에요.", "Short green plants that cover the ground.", "The grass is wet with dew."),
	("TULIP", "🌷", "튤립. 컵 모양의 꽃이에요.", "A spring flower shaped like a cup.", "The tulip opens in spring."),
	("FLOWER", "🌸", "꽃. 식물의 예쁜 부분이에요.", "The colorful part of a plant.", "The flower smells sweet."),
],
[
	("BAMBOO", "🎋", "대나무. 곧고 빠르게 자라요.", "A tall grass that grows very fast.", "Bamboo grows very fast."),
	("CACTUS", "🌵", "선인장. 가시가 있고 물을 저장해요.", "A desert plant with sharp spines.", "The cactus stores water."),
	("MUSHROOM", "🍄", "버섯. 우산 모양으로 자라요.", "A soft growth shaped like an umbrella.", "A mushroom grows in shade."),
	("SUNFLOWER", "🌻", "해바라기. 해를 따라 도는 꽃이에요.", "A tall yellow flower that faces the sun.", "The sunflower faces the sun."),
])
