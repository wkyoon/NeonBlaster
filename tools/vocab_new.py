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


# ============================================================
# 확장 1차분 — 새 테마 12개 (144단어)
# 목표 어휘 1000개를 향한 첫 묶음. 규칙은 파일 맨 위 주석 참조.
# ============================================================

theme("HEALTH", "건강", "HEALTH", "PULSE", (0.05, 0.10, 0.10), (0.4, 1.0, 0.85), (0.6, 1.0, 0.9),
[
	("BONE", "🦴", "뼈. 몸을 받쳐 주는 단단한 부분이에요.", "A hard white part inside the body.", "The dog found a big bone."),
	("PILL", "💊", "알약. 물과 함께 삼켜요.", "A small round medicine you swallow.", "She takes one pill a day."),
	("MASK", "😷", "마스크. 입과 코를 덮어요.", "A cover you wear over your mouth and nose.", "He wears a mask on the bus."),
	("COUGH", "🤧", "기침. 목이 아플 때 나와요.", "A sudden loud sound from a sore throat.", "My cough is getting better."),
	("FEVER", "🤒", "열. 몸이 뜨거워지는 증상이에요.", "A body that is hotter than normal.", "The baby has a small fever."),
	("TOOTH", "🦷", "이. 음식을 씹는 데 써요.", "A hard white part in your mouth for chewing.", "One tooth hurts a little."),
	("HEART", "❤️", "심장. 가슴에서 쿵쿵 뛰어요.", "The organ that pumps blood in your chest.", "I can hear my heart beat."),
	("SYRINGE", "💉", "주사기. 약을 몸에 넣어요.", "A tool with a needle used to give medicine.", "The nurse holds a syringe."),
],
[
	("BANDAGE", "🩹", "반창고. 다친 곳에 붙여요.", "A strip you put over a cut.", "Put a bandage on your knee."),
	("VITAMIN", "🍊", "비타민. 몸에 좋은 영양분이에요.", "Something in food that keeps you healthy.", "Fruit is full of vitamin C."),
	("MEDICINE", "💊", "약. 아플 때 먹어요.", "Something you take to feel better.", "Take your medicine after lunch."),
	("THERMOMETER", "🌡️", "체온계. 열을 재는 도구예요.", "A tool that measures how hot something is.", "The thermometer shows a fever."),
])

theme("TRAVEL", "여행", "TRAVEL", "STAR", (0.06, 0.07, 0.13), (0.5, 0.85, 1.0), (0.7, 0.95, 1.0),
[
	("BAG", "🎒", "가방. 짐을 넣어 들고 다녀요.", "Something you carry your things in.", "My bag is very heavy."),
	("TENT", "⛺", "텐트. 밖에서 잘 때 쳐요.", "A cloth shelter you sleep in outdoors.", "We sleep in a small tent."),
	("VISA", "🛂", "비자. 다른 나라에 들어갈 허가예요.", "Permission to enter another country.", "I need a visa for that trip."),
	("BEACH", "🏖️", "해변. 바다 옆 모래밭이에요.", "Sand next to the sea.", "The beach is warm today."),
	("TICKET", "🎫", "표. 타거나 들어갈 때 내요.", "A paper that lets you enter or ride.", "Keep your ticket in your bag."),
	("CAMERA", "📷", "사진기. 사진을 찍어요.", "A device for taking pictures.", "She holds the camera up."),
	("JOURNEY", "🧭", "여정. 긴 여행길이에요.", "A long trip from one place to another.", "Our journey starts at dawn."),
	("LUGGAGE", "🧳", "짐. 여행에 가져가는 가방들이에요.", "The bags you take on a trip.", "My luggage is still in the car."),
],
[
	("PASSPORT", "🛂", "여권. 나라 밖으로 나갈 때 필요해요.", "A book that proves who you are abroad.", "Show your passport at the gate."),
	("SOUVENIR", "🎁", "기념품. 여행에서 사 오는 물건이에요.", "Something you buy to remember a place.", "I bought a small souvenir."),
	("SUITCASE", "🧳", "여행 가방. 바퀴가 달려 있어요.", "A flat bag with wheels for clothes.", "The suitcase will not close."),
	("ADVENTURE", "🏔️", "모험. 신나고 새로운 경험이에요.", "An exciting and unusual experience.", "It was a real adventure."),
])

theme("AIRPORT", "공항", "AIRPORT", "GEAR", (0.05, 0.08, 0.12), (0.6, 0.9, 1.0), (0.8, 0.95, 1.0),
[
	("GATE", "🛫", "탑승구. 비행기를 타러 가는 문이에요.", "The door where you get on a plane.", "Our gate is number nine."),
	("BELT", "🧷", "안전벨트. 앉으면 매요.", "A strap that holds you in your seat.", "Please fasten your belt."),
	("SEAT", "💺", "좌석. 앉는 자리예요.", "A place to sit down.", "My seat is by the window."),
	("CABIN", "🛩️", "객실. 비행기 안 사람이 타는 곳이에요.", "The part of a plane where people sit.", "The cabin is quiet now."),
	("FLIGHT", "✈️", "비행. 비행기가 가는 길이에요.", "A trip made by plane.", "The flight takes two hours."),
	("RUNWAY", "🛫", "활주로. 비행기가 달리는 길이에요.", "The long road a plane rolls on.", "The plane waits on the runway."),
	("LANDING", "🛬", "착륙. 비행기가 땅에 내려요.", "The moment a plane touches the ground.", "The landing was very smooth."),
	("BOARDING", "🎫", "탑승. 비행기에 올라타요.", "Getting on a plane or ship.", "Boarding starts in ten minutes."),
],
[
	("TERMINAL", "🏢", "터미널. 공항의 큰 건물이에요.", "The big building at an airport.", "We meet at terminal two."),
	("DEPARTURE", "🛫", "출발. 떠나는 것이에요.", "The act of leaving a place.", "Check the departure time."),
	("PASSENGER", "🧍", "승객. 타고 가는 사람이에요.", "A person who travels in a vehicle.", "Every passenger is seated."),
	("RESERVATION", "📋", "예약. 미리 자리를 잡아 두는 거예요.", "An arrangement made in advance.", "I have a reservation for two."),
])

theme("KITCHEN", "주방", "KITCHEN", "BLOB", (0.11, 0.07, 0.05), (1.0, 0.7, 0.4), (1.0, 0.85, 0.55),
[
	("POT", "🍲", "냄비. 국을 끓여요.", "A deep round dish for cooking.", "The pot is on the stove."),
	("PAN", "🍳", "프라이팬. 부치거나 볶아요.", "A flat dish for frying food.", "Put the egg in the pan."),
	("BOWL", "🥣", "그릇. 둥글고 깊어요.", "A round deep dish for food.", "She fills the bowl with soup."),
	("FORK", "🍴", "포크. 찍어서 먹어요.", "A tool with points for picking up food.", "Use a fork for the salad."),
	("KNIFE", "🔪", "칼. 자를 때 써요.", "A sharp tool for cutting.", "This knife cuts bread well."),
	("SPOON", "🥄", "숟가락. 떠서 먹어요.", "A round tool for eating liquid food.", "Stir it with a spoon."),
	("PLATE", "🍽️", "접시. 음식을 담아요.", "A flat dish you put food on.", "My plate is already empty."),
	("KETTLE", "🫖", "주전자. 물을 끓여요.", "A pot used to boil water.", "The kettle is boiling now."),
],
[
	("FRIDGE", "🧊", "냉장고. 음식을 차게 보관해요.", "A cold box that keeps food fresh.", "The milk is in the fridge."),
	("BLENDER", "🥤", "믹서. 갈아서 음료를 만들어요.", "A machine that mixes food into liquid.", "The blender makes a loud noise."),
	("CUPBOARD", "🗄️", "찬장. 그릇을 넣어 두는 곳이에요.", "A closed shelf for dishes and food.", "The cups are in the cupboard."),
	("MICROWAVE", "♨️", "전자레인지. 음식을 빨리 데워요.", "A machine that heats food quickly.", "Warm the rice in the microwave."),
])

theme("VEGETABLE", "채소", "VEGETABLE", "LEAF", (0.05, 0.11, 0.06), (0.5, 1.0, 0.45), (0.7, 1.0, 0.6),
[
	("PEA", "🫛", "완두콩. 작고 둥근 초록 콩이에요.", "A small round green seed you eat.", "One pea rolled off the plate."),
	("CORN", "🌽", "옥수수. 노란 알이 줄지어 있어요.", "A tall plant with yellow seeds in rows.", "We grill corn in summer."),
	("BEAN", "🫘", "콩. 껍질 안에 씨가 있어요.", "A seed that grows inside a pod.", "Every bean is soft now."),
	("LEEK", "🌿", "대파. 길고 흰 줄기가 있어요.", "A long white vegetable that tastes like onion.", "Cut the leek into rings."),
	("ONION", "🧅", "양파. 껍질을 벗기면 눈이 매워요.", "A round vegetable with many layers.", "This onion makes me cry."),
	("GARLIC", "🧄", "마늘. 향이 아주 강해요.", "A small strong-smelling bulb.", "Add garlic to the soup."),
	("CARROT", "🥕", "당근. 주황색이고 길어요.", "A long orange root you can eat.", "The rabbit eats a carrot."),
	("PEPPER", "🌶️", "고추. 매운맛이 나요.", "A vegetable that can taste hot.", "That red pepper is very hot."),
],
[
	("POTATO", "🥔", "감자. 땅속에서 자라요.", "A round root that grows under the ground.", "Bake the potato for an hour."),
	("SPINACH", "🥬", "시금치. 초록 잎을 먹어요.", "A green leaf vegetable full of iron.", "Spinach makes you strong."),
	("CABBAGE", "🥬", "양배추. 잎이 겹겹이 싸여 있어요.", "A round vegetable with tight leaves.", "She cuts the cabbage thin."),
	("CUCUMBER", "🥒", "오이. 길고 시원한 맛이에요.", "A long green vegetable that tastes cool.", "The cucumber is fresh and cold."),
])

theme("BIRD", "새", "BIRD", "PAW", (0.07, 0.09, 0.12), (0.7, 0.9, 1.0), (0.85, 0.95, 1.0),
[
	("HEN", "🐔", "암탉. 달걀을 낳아요.", "A female chicken that lays eggs.", "The hen sits on her eggs."),
	("DUCK", "🦆", "오리. 물에서 헤엄쳐요.", "A water bird with a flat beak.", "A duck swims in the pond."),
	("CROW", "🐦", "까마귀. 검고 울음소리가 커요.", "A big black bird with a loud call.", "The crow sits on the wire."),
	("DOVE", "🕊️", "비둘기. 평화를 뜻해요.", "A white bird that means peace.", "A dove lands on the roof."),
	("SWAN", "🦢", "백조. 목이 길고 하얘요.", "A large white bird with a long neck.", "The swan glides on the lake."),
	("EAGLE", "🦅", "독수리. 높이 날고 눈이 좋아요.", "A large bird that flies very high.", "The eagle watches from above."),
	("ROBIN", "🐦", "울새. 가슴이 붉어요.", "A small bird with a red chest.", "A robin sings every morning."),
	("PARROT", "🦜", "앵무새. 말을 따라 해요.", "A colorful bird that copies words.", "My parrot says my name."),
],
[
	("TURKEY", "🦃", "칠면조. 크고 꼬리를 펴요.", "A large bird with a wide tail.", "The turkey spreads its tail."),
	("PEACOCK", "🦚", "공작. 꼬리가 아주 화려해요.", "A bird with a huge bright tail.", "The peacock opens its tail."),
	("FLAMINGO", "🦩", "플라밍고. 분홍색이고 다리가 길어요.", "A pink bird that stands on one leg.", "The flamingo stands very still."),
	("WOODPECKER", "🪶", "딱따구리. 나무를 두드려요.", "A bird that knocks holes in trees.", "The woodpecker taps the old tree."),
])

theme("TREE", "나무", "TREE", "LEAF", (0.05, 0.09, 0.05), (0.45, 0.95, 0.5), (0.65, 1.0, 0.65),
[
	("ELM", "🌳", "느티나무. 잎이 넓게 퍼져요.", "A tall shade tree with wide leaves.", "An old elm stands by the road."),
	("BARK", "🪵", "나무껍질. 줄기를 덮고 있어요.", "The hard cover on a tree trunk.", "The bark feels rough."),
	("TWIG", "🌿", "잔가지. 아주 얇은 가지예요.", "A very thin branch.", "A twig snapped under my shoe."),
	("PALM", "🌴", "야자나무. 더운 곳에서 자라요.", "A tall tree with big leaves on top.", "One palm leans over the sand."),
	("MAPLE", "🍁", "단풍나무. 가을에 잎이 붉어져요.", "A tree whose leaves turn red in autumn.", "The maple turns red in fall."),
	("BIRCH", "🌲", "자작나무. 껍질이 하얘요.", "A tree with thin white bark.", "The birch shines in the snow."),
	("BRANCH", "🌿", "가지. 줄기에서 뻗어 나와요.", "A part that grows out from a trunk.", "A bird sits on the branch."),
	("WILLOW", "🌾", "버드나무. 가지가 늘어져요.", "A tree with long hanging branches.", "The willow bends to the water."),
],
[
	("FOREST", "🌲", "숲. 나무가 아주 많은 곳이에요.", "A large area covered with trees.", "The forest is dark and cool."),
	("ORCHARD", "🍎", "과수원. 과일나무를 기르는 밭이에요.", "A field where fruit trees grow.", "The orchard smells of apples."),
	("CHESTNUT", "🌰", "밤. 가시 껍질 안에 들어 있어요.", "A brown nut inside a spiky shell.", "He roasts one chestnut."),
	("EUCALYPTUS", "🌿", "유칼립투스. 잎에서 시원한 향이 나요.", "A tree with leaves that smell fresh.", "Koalas eat eucalyptus leaves."),
])

theme("FLOWER", "꽃", "FLOWER", "LEAF", (0.10, 0.05, 0.10), (1.0, 0.6, 0.9), (1.0, 0.8, 0.95),
[
	("BUD", "🌷", "꽃봉오리. 아직 피지 않은 꽃이에요.", "A flower before it opens.", "A tiny bud opened today."),
	("ROSE", "🌹", "장미. 향이 좋고 가시가 있어요.", "A flower with a sweet smell and thorns.", "He gives her one rose."),
	("LILY", "🪷", "백합. 크고 향이 진해요.", "A large flower with a strong smell.", "The lily floats on the pond."),
	("IRIS", "🌸", "아이리스. 보라색 잎이 펼쳐져요.", "A flower with wide purple petals.", "The iris blooms by the gate."),
	("PETAL", "🌸", "꽃잎. 꽃의 얇은 잎이에요.", "One thin colored part of a flower.", "A petal fell on the desk."),
	("DAISY", "🌼", "데이지. 가운데가 노랗고 작아요.", "A small flower with a yellow center.", "She picks a white daisy."),
	("POLLEN", "🐝", "꽃가루. 벌이 옮겨 줘요.", "Yellow dust that bees carry.", "Pollen covers the window."),
	("ORCHID", "🪻", "난초. 모양이 특이하고 귀해요.", "An unusual flower with a strange shape.", "The orchid needs little water."),
],
[
	("BLOSSOM", "🌸", "만개한 꽃. 나무에 가득 피어요.", "A flower on a fruit tree.", "The blossom covers the branch."),
	("LAVENDER", "💜", "라벤더. 연보라색이고 향이 좋아요.", "A purple plant with a calm smell.", "Lavender helps me sleep."),
	("CARNATION", "🌺", "카네이션. 감사할 때 드려요.", "A ruffled flower given as thanks.", "I give my mother a carnation."),
	("CHRYSANTHEMUM", "🌼", "국화. 가을에 피는 꽃이에요.", "A round autumn flower with many petals.", "The chrysanthemum blooms in fall."),
])

theme("TOOL", "공구", "TOOL", "GEAR", (0.08, 0.08, 0.10), (0.85, 0.85, 0.95), (1.0, 1.0, 1.0),
[
	("SAW", "🪚", "톱. 나무를 자를 때 써요.", "A tool with teeth for cutting wood.", "The saw cuts through the board."),
	("NAIL", "🔨", "못. 망치로 박아요.", "A thin metal pin you hammer in.", "Hit the nail once more."),
	("BOLT", "🔩", "볼트. 너트와 짝을 이뤄요.", "A thick metal pin with a thread.", "Tighten the bolt by hand."),
	("TAPE", "📏", "테이프. 붙이거나 길이를 재요.", "A long strip used to stick or measure.", "Pull the tape a little more."),
	("DRILL", "🪛", "드릴. 구멍을 뚫어요.", "A tool that makes round holes.", "The drill is very loud."),
	("SCREW", "🔩", "나사. 돌려서 박아요.", "A metal pin you turn to fasten.", "One screw is missing."),
	("HAMMER", "🔨", "망치. 두드려서 박아요.", "A heavy tool used to hit nails.", "He swings the hammer down."),
	("WRENCH", "🔧", "렌치. 볼트를 조여요.", "A tool for turning bolts.", "Hand me the small wrench."),
],
[
	("LADDER", "🪜", "사다리. 높은 곳에 올라가요.", "Steps you climb to reach high places.", "The ladder leans on the wall."),
	("SHOVEL", "🪓", "삽. 땅을 파요.", "A tool for digging soil.", "He digs with a wide shovel."),
	("TOOLBOX", "🧰", "공구함. 도구를 담아 두어요.", "A box that holds tools.", "The toolbox is under the bench."),
	("SCREWDRIVER", "🪛", "드라이버. 나사를 돌려요.", "A tool for turning screws.", "I need a thin screwdriver."),
])

theme("MONEY", "돈", "MONEY", "STAR", (0.09, 0.09, 0.05), (1.0, 0.85, 0.35), (1.0, 0.95, 0.6),
[
	("COIN", "🪙", "동전. 둥글고 단단한 돈이에요.", "A small round piece of metal money.", "One coin fell on the floor."),
	("CASH", "💵", "현금. 종이돈과 동전이에요.", "Money in notes and coins.", "I pay in cash today."),
	("BILL", "💴", "지폐. 종이로 된 돈이에요.", "A paper note of money.", "He folds the bill twice."),
	("SAVE", "🏦", "저축하다. 돈을 모아 둬요.", "To keep money for later.", "I save a little each week."),
	("PRICE", "🏷️", "값. 물건이 얼마인지예요.", "How much something costs.", "The price is too high."),
	("WALLET", "👛", "지갑. 돈을 넣어 다녀요.", "A small case for money.", "My wallet is in the bag."),
	("CREDIT", "💳", "신용. 나중에 내겠다는 약속이에요.", "A promise to pay later.", "She buys it on credit."),
	("BUDGET", "📊", "예산. 쓸 돈을 미리 정해요.", "A plan for how to spend money.", "Our budget is very tight."),
],
[
	("INCOME", "💰", "수입. 벌어들이는 돈이에요.", "The money you earn.", "His income grew this year."),
	("PAYMENT", "🧾", "지불. 돈을 내는 거예요.", "Money given for something.", "The payment is due today."),
	("DISCOUNT", "🏷️", "할인. 값을 깎아 줘요.", "An amount taken off the price.", "They give a small discount."),
	("INVESTMENT", "📈", "투자. 늘리려고 돈을 넣어요.", "Money put in to grow more money.", "It was a smart investment."),
])

theme("FARM", "농장", "FARM", "PAW", (0.09, 0.08, 0.05), (1.0, 0.8, 0.45), (1.0, 0.9, 0.6),
[
	("COW", "🐄", "소. 우유를 줘요.", "A large farm animal that gives milk.", "The cow eats green grass."),
	("PIG", "🐖", "돼지. 코가 넓적해요.", "A pink farm animal with a flat nose.", "A pig sleeps in the mud."),
	("HAY", "🌾", "건초. 말린 풀이에요.", "Dry grass fed to animals.", "The hay smells sweet."),
	("BARN", "🏚️", "헛간. 동물과 짐을 두는 곳이에요.", "A big farm building for animals.", "The horses go in the barn."),
	("GOAT", "🐐", "염소. 뿔이 있고 잘 올라가요.", "A farm animal with horns that climbs.", "The goat climbs the rock."),
	("SHEEP", "🐑", "양. 털이 두껍고 폭신해요.", "A farm animal with thick wool.", "We count every sheep."),
	("HORSE", "🐴", "말. 빠르게 달려요.", "A large animal people ride.", "The horse runs very fast."),
	("FENCE", "🚧", "울타리. 밭이나 마당을 둘러요.", "A wall of wood or wire around land.", "The fence needs a new board."),
],
[
	("HARVEST", "🌾", "수확. 다 자란 것을 거둬요.", "Gathering crops when they are ready.", "The harvest starts in autumn."),
	("PASTURE", "🐄", "목초지. 동물이 풀을 뜯는 들이에요.", "A field where animals eat grass.", "The cows walk to the pasture."),
	("TRACTOR", "🚜", "트랙터. 밭을 가는 기계예요.", "A strong machine that pulls farm tools.", "The tractor turns the soil."),
	("SCARECROW", "🎃", "허수아비. 새를 쫓아요.", "A figure that frightens birds away.", "The scarecrow wears an old hat."),
])

theme("DESSERT", "디저트", "DESSERT", "BLOB", (0.11, 0.06, 0.08), (1.0, 0.6, 0.75), (1.0, 0.8, 0.9),
[
	("PIE", "🥧", "파이. 속을 채워 구워요.", "A baked dish with filling inside.", "The apple pie is warm."),
	("JAM", "🍯", "잼. 과일을 졸여 만들어요.", "Sweet fruit spread for bread.", "Spread jam on the toast."),
	("CAKE", "🍰", "케이크. 생일에 먹어요.", "A soft sweet food for parties.", "We cut the cake together."),
	("TART", "🥧", "타르트. 얇은 껍질에 과일을 올려요.", "A small open pie with fruit on top.", "This tart has fresh berries."),
	("HONEY", "🍯", "꿀. 벌이 만든 단 액체예요.", "A sweet liquid made by bees.", "Honey drips from the spoon."),
	("CANDY", "🍬", "사탕. 입에서 천천히 녹아요.", "A small hard sweet you suck.", "One candy is left."),
	("DONUT", "🍩", "도넛. 가운데 구멍이 있어요.", "A round sweet cake with a hole.", "The donut is still warm."),
	("COOKIE", "🍪", "쿠키. 바삭하게 구운 과자예요.", "A small flat sweet baked crisp.", "She bakes one more cookie."),
],
[
	("WAFFLE", "🧇", "와플. 네모 무늬가 있어요.", "A crisp cake with square holes.", "The waffle holds the syrup."),
	("PUDDING", "🍮", "푸딩. 부드럽게 떠먹어요.", "A soft sweet food eaten with a spoon.", "The pudding wobbles a little."),
	("BROWNIE", "🍫", "브라우니. 초콜릿을 넣어 구워요.", "A dense chocolate cake square.", "One brownie is enough."),
	("ICECREAM", "🍨", "아이스크림. 차갑고 달아요.", "A frozen sweet food.", "My icecream melts too fast."),
])


# ============================================================
# 확장 2차분 — 동사·형용사 8개 테마 (96단어)
# ⚠️ 지금까지는 전부 구체 명사였다. 명사만으로는 문장을 못 만든다 —
#    동사·형용사가 들어와야 예문이 실제 영어처럼 읽힌다.
# ⚠️ 이미 사전에 있는 동사(RUN JUMP SWIM CLIMB MOVE PLAY BEAT SHINE SAVE)와
#    형용사(HOT COLD WARM CALM + 감정어)는 제외했다.
# ============================================================

theme("ACTION", "동작", "ACTION", "PULSE", (0.10, 0.06, 0.09), (1.0, 0.55, 0.8), (1.0, 0.75, 0.9),
[
	("EAT", "🍽️", "먹다. 음식을 입에 넣어요.", "To put food in your mouth.", "We eat at seven every day."),
	("SIT", "🪑", "앉다. 의자에 몸을 내려요.", "To rest on a chair or the ground.", "Please sit next to me."),
	("CUT", "✂️", "자르다. 둘로 나눠요.", "To divide something with a sharp tool.", "Cut the paper in half."),
	("READ", "📖", "읽다. 글을 눈으로 따라가요.", "To look at words and understand them.", "I read one page a night."),
	("WALK", "🚶", "걷다. 다리로 천천히 가요.", "To move on your feet slowly.", "They walk to school together."),
	("WASH", "🧼", "씻다. 물로 깨끗하게 해요.", "To clean something with water.", "Wash your hands before lunch."),
	("SPEAK", "🗣️", "말하다. 소리를 내어 전해요.", "To say words out loud.", "She speaks very softly."),
	("WRITE", "✍️", "쓰다. 글자를 남겨요.", "To make letters with a pen.", "Write your name on top."),
],
[
	("SLEEP", "😴", "자다. 눈을 감고 쉬어요.", "To rest with your eyes closed.", "The cat sleeps all day."),
	("LISTEN", "👂", "듣다. 소리에 귀를 기울여요.", "To pay attention to a sound.", "Listen to the rain outside."),
	("FOLLOW", "👣", "따라가다. 뒤를 좇아요.", "To go after someone.", "The puppy follows me home."),
	("REMEMBER", "🧠", "기억하다. 잊지 않고 떠올려요.", "To keep something in your mind.", "I remember that song well."),
])

theme("MOTION", "움직임", "MOTION", "PULSE", (0.06, 0.09, 0.11), (0.5, 0.9, 1.0), (0.7, 1.0, 1.0),
[
	("SPIN", "🌀", "돌다. 제자리에서 빙 돌아요.", "To turn around quickly.", "The coin spins on the table."),
	("ROLL", "🎳", "구르다. 굴러서 나아가요.", "To turn over and over while moving.", "The ball rolls down the hill."),
	("DIVE", "🤿", "뛰어들다. 머리부터 물에 들어가요.", "To go head first into water.", "He dives into the cold pool."),
	("SLIDE", "🛝", "미끄러지다. 매끈하게 내려가요.", "To move smoothly along a surface.", "Children slide down the ramp."),
	("CRAWL", "🐛", "기다. 배를 붙이고 나아가요.", "To move slowly on hands and knees.", "The baby crawls to the door."),
	("DANCE", "💃", "춤추다. 음악에 맞춰 움직여요.", "To move your body to music.", "They dance until midnight."),
	("FLOAT", "🎈", "떠오르다. 가라앉지 않아요.", "To stay on top of water or air.", "The balloon floats away."),
	("BOUNCE", "🏀", "튀다. 부딪혀 되올라와요.", "To spring back after hitting something.", "The ball bounces twice."),
],
[
	("GALLOP", "🐎", "질주하다. 말이 빠르게 달려요.", "To run fast like a horse.", "The horse gallops across the field."),
	("TUMBLE", "🤸", "굴러 넘어지다. 데굴데굴 구르며 넘어져요.", "To fall while rolling over.", "He tumbles onto the grass."),
	("SPRINT", "🏃", "전력 질주하다. 짧게 아주 빨리 달려요.", "To run as fast as you can for a short way.", "She sprints to the finish line."),
	("SOMERSAULT", "🤸", "공중제비. 몸을 한 바퀴 돌려요.", "A jump where you turn all the way over.", "He did one clean somersault."),
])

theme("SENSE", "감각", "SENSE", "STAR", (0.08, 0.06, 0.12), (0.8, 0.7, 1.0), (0.9, 0.85, 1.0),
[
	("SEE", "👀", "보다. 눈으로 알아봐요.", "To notice something with your eyes.", "I see a bird on the roof."),
	("HEAR", "👂", "듣다. 소리가 귀에 들어와요.", "To notice a sound with your ears.", "Do you hear that noise?"),
	("FEEL", "🤲", "느끼다. 몸이나 마음으로 알아요.", "To notice something by touch or emotion.", "I feel the warm sun."),
	("TASTE", "👅", "맛보다. 혀로 맛을 알아요.", "To notice flavor with your tongue.", "Taste the soup for me."),
	("SMELL", "👃", "냄새를 맡다. 코로 알아봐요.", "To notice something with your nose.", "The flowers smell sweet."),
	("TOUCH", "✋", "만지다. 손을 대어 봐요.", "To put your hand on something.", "Do not touch the hot pan."),
	("WATCH", "👁️", "지켜보다. 오래 바라봐요.", "To look at something for a while.", "We watch the clouds move."),
	("SILENCE", "🤫", "고요. 아무 소리도 없어요.", "A time with no sound at all.", "The silence woke me up."),
],
[
	("WHISPER", "🤫", "속삭임. 아주 작은 목소리예요.", "A very quiet way of speaking.", "She answers in a whisper."),
	("TEXTURE", "🧵", "질감. 만졌을 때의 느낌이에요.", "How a surface feels when touched.", "The texture is rough and dry."),
	("LOUDNESS", "🔊", "소리 크기. 얼마나 큰지예요.", "How strong a sound is.", "Lower the loudness a little."),
	("FRAGRANCE", "🌸", "향기. 좋은 냄새예요.", "A pleasant smell.", "The fragrance fills the room."),
])

theme("SIZE", "크기", "SIZE", "BLOB", (0.07, 0.09, 0.06), (0.6, 1.0, 0.6), (0.8, 1.0, 0.8),
[
	("BIG", "🐘", "큰. 크기가 많이 나가요.", "Large in size.", "That is a big elephant."),
	("TINY", "🐜", "아주 작은. 눈에 겨우 보여요.", "Extremely small.", "A tiny ant walks by."),
	("WIDE", "↔️", "넓은. 좌우가 멀어요.", "Large from side to side.", "The river is very wide."),
	("TALL", "🦒", "키가 큰. 위로 길어요.", "High from top to bottom.", "The giraffe is so tall."),
	("DEEP", "🌊", "깊은. 아래로 멀어요.", "Going far down.", "The lake is deep here."),
	("SMALL", "🐁", "작은. 크기가 적어요.", "Little in size.", "A small mouse hides there."),
	("SHORT", "📏", "짧은. 길이가 적어요.", "Not long or not tall.", "This rope is too short."),
	("NARROW", "🚪", "좁은. 폭이 적어요.", "Small from side to side.", "The narrow path turns left."),
],
[
	("LITTLE", "🤏", "조그마한. 아주 조금이에요.", "Small in size or amount.", "Just a little salt, please."),
	("MASSIVE", "🏔️", "거대한. 엄청나게 커요.", "Extremely large and heavy.", "A massive rock blocks the road."),
	("GIGANTIC", "🦕", "굉장히 큰. 상상보다 커요.", "Much bigger than normal.", "The gigantic tree hides the sky."),
	("ENORMOUS", "🐋", "막대한. 아주아주 커요.", "Very much larger than usual.", "An enormous whale passed by."),
])

theme("FLAVOR", "맛", "FLAVOR", "BLOB", (0.11, 0.08, 0.05), (1.0, 0.75, 0.4), (1.0, 0.9, 0.6),
[
	("SOUR", "🍋", "신. 레몬 같은 맛이에요.", "Having a sharp taste like lemon.", "This lemon is very sour."),
	("MILD", "🥛", "순한. 세지 않은 맛이에요.", "Not strong or spicy.", "The sauce is mild and soft."),
	("SALTY", "🧂", "짠. 소금 맛이 나요.", "Tasting of salt.", "The soup is a bit salty."),
	("SWEET", "🍬", "단. 설탕 맛이 나요.", "Tasting of sugar.", "This tea is too sweet."),
	("SPICY", "🌶️", "매운. 혀가 따끔해요.", "Having a hot burning taste.", "The spicy noodles made me cry."),
	("FRESH", "🥬", "신선한. 갓 나온 상태예요.", "Newly made or picked.", "The bread is still fresh."),
	("BITTER", "☕", "쓴. 커피 같은 맛이에요.", "Having a sharp unpleasant taste.", "Black coffee tastes bitter."),
	("SAVORY", "🍜", "감칠맛 나는. 짭짤하고 깊어요.", "Salty and full of flavor, not sweet.", "The savory broth smells great."),
],
[
	("CREAMY", "🍦", "크림 같은. 부드럽고 진해요.", "Smooth and thick like cream.", "The sauce is rich and creamy."),
	("CRUNCHY", "🥕", "아삭한. 씹으면 소리가 나요.", "Making a sharp sound when bitten.", "These carrots are very crunchy."),
	("DELICIOUS", "😋", "아주 맛있는. 정말 맛나요.", "Tasting extremely good.", "That was a delicious meal."),
	("FLAVORFUL", "🍲", "풍미가 좋은. 맛이 가득해요.", "Full of strong good taste.", "The stew is warm and flavorful."),
])

theme("TEMPERATURE", "온도", "TEMPERATURE", "STAR", (0.06, 0.08, 0.12), (0.6, 0.85, 1.0), (0.8, 0.95, 1.0),
[
	("ICY", "🧊", "얼음처럼 찬. 매우 차가워요.", "As cold as ice.", "The icy wind hurts my face."),
	("COOL", "🌬️", "시원한. 조금 차가워요.", "A little cold, in a pleasant way.", "A cool breeze came in."),
	("DAMP", "💧", "축축한. 조금 젖어 있어요.", "Slightly wet.", "The towel is still damp."),
	("HUMID", "💦", "습한. 공기에 물기가 많아요.", "Having a lot of water in the air.", "Summer here is very humid."),
	("CHILLY", "🥶", "쌀쌀한. 몸이 오슬오슬해요.", "Cold enough to feel uncomfortable.", "The morning is chilly today."),
	("FROZEN", "❄️", "얼어붙은. 단단하게 얼었어요.", "Turned hard because of cold.", "The pond is frozen solid."),
	("BURNING", "🔥", "타는. 불처럼 뜨거워요.", "So hot that it feels like fire.", "The sand is burning hot."),
	("BOILING", "♨️", "끓는. 물이 펄펄 끓어요.", "Hot enough to bubble.", "The water is boiling now."),
],
[
	("FREEZING", "🧊", "몹시 추운. 얼 만큼 추워요.", "Cold enough to turn water to ice.", "It is freezing outside tonight."),
	("LUKEWARM", "🌡️", "미지근한. 뜨겁지도 차갑지도 않아요.", "Only slightly warm.", "The tea went lukewarm."),
	("SCORCHING", "☀️", "타는 듯한. 햇볕이 아주 강해요.", "Extremely hot, like the summer sun.", "It was a scorching afternoon."),
	("TEMPERATE", "🌤️", "온화한. 너무 춥지도 덥지도 않아요.", "Never very hot or very cold.", "This island has a temperate climate."),
])

theme("SPEED", "속도", "SPEED", "PULSE", (0.09, 0.06, 0.11), (0.9, 0.6, 1.0), (1.0, 0.8, 1.0),
[
	("FAST", "⚡", "빠른. 아주 빨리 가요.", "Moving at high speed.", "That train is really fast."),
	("SLOW", "🐢", "느린. 천천히 가요.", "Moving with little speed.", "The turtle is slow but sure."),
	("RUSH", "💨", "서두름. 급하게 움직여요.", "To move or act in a hurry.", "Do not rush your breakfast."),
	("QUICK", "🐇", "재빠른. 순식간이에요.", "Done in a very short time.", "Take a quick look inside."),
	("RAPID", "🌊", "급속한. 빠르게 이어져요.", "Happening very fast.", "The river has rapid water."),
	("STEADY", "🚶", "꾸준한. 일정하게 계속해요.", "Moving at the same speed all along.", "Keep a steady pace uphill."),
	("SUDDEN", "💥", "갑작스러운. 예고 없이 와요.", "Happening without warning.", "A sudden noise woke us."),
	("GRADUAL", "📉", "점진적인. 조금씩 변해요.", "Changing slowly over time.", "The gradual climb is easy."),
],
[
	("INSTANT", "⏱️", "즉각적인. 바로 그 순간이에요.", "Happening immediately.", "The reply was instant."),
	("SLUGGISH", "🦥", "느릿한. 힘없이 느려요.", "Moving slowly and without energy.", "The old fan is sluggish."),
	("IMMEDIATE", "⏰", "즉시의. 조금도 기다리지 않아요.", "Done at once, with no delay.", "We need an immediate answer."),
	("ACCELERATE", "🏎️", "가속하다. 점점 빨라져요.", "To go faster and faster.", "The car begins to accelerate."),
])

theme("STATE", "상태", "STATE", "GEAR", (0.08, 0.08, 0.09), (0.85, 0.9, 1.0), (0.95, 1.0, 1.0),
[
	("NEW", "✨", "새로운. 막 생겼어요.", "Made or bought a short time ago.", "These are my new shoes."),
	("OLD", "🧓", "오래된. 나이가 많아요.", "Having lived or existed a long time.", "This old clock still works."),
	("WET", "💧", "젖은. 물이 묻었어요.", "Covered with water.", "My socks are all wet."),
	("DRY", "🌵", "마른. 물기가 없어요.", "Having no water in it.", "The towel is dry again."),
	("FULL", "🍽️", "가득한. 더 들어갈 자리가 없어요.", "Holding as much as possible.", "The glass is almost full."),
	("EMPTY", "🕳️", "빈. 아무것도 없어요.", "Having nothing inside.", "The box came back empty."),
	("CLEAN", "🧼", "깨끗한. 더러움이 없어요.", "Free from dirt.", "Keep your desk clean."),
	("DIRTY", "🧹", "더러운. 먼지가 묻었어요.", "Covered with dirt.", "His hands are very dirty."),
],
[
	("BROKEN", "💔", "부서진. 못 쓰게 됐어요.", "Damaged and no longer working.", "The broken chair wobbles."),
	("PERFECT", "💯", "완벽한. 흠이 하나도 없어요.", "Having nothing wrong at all.", "That was a perfect throw."),
	("FRAGILE", "🥚", "깨지기 쉬운. 조심해야 해요.", "Easily broken.", "This box is fragile, be careful."),
	("COMPLETE", "✅", "완성된. 빠진 것이 없어요.", "Having all its parts.", "My collection is complete."),
])


# ============================================================
# 확장 3차분 — 새 테마 12개 (144단어)
# ⚠️ 테마 id 가 기존 **단어**와 겹치지 않게 이름을 골랐다:
#    MONTH·BOOK·LIBRARY·RESTAURANT 는 이미 단어라 CALENDAR·READING·DINING 으로 두었다.
# ============================================================

theme("CALENDAR", "달", "CALENDAR", "STAR", (0.07, 0.07, 0.11), (0.7, 0.8, 1.0), (0.85, 0.9, 1.0),
[
	("MAY", "🌷", "5월. 꽃이 많이 피는 달이에요.", "The fifth month of the year.", "My birthday is in May."),
	("JUNE", "☀️", "6월. 여름이 시작돼요.", "The sixth month of the year.", "June brings warm days."),
	("JULY", "🏖️", "7월. 가장 더운 달이에요.", "The seventh month of the year.", "We swim a lot in July."),
	("APRIL", "🌸", "4월. 봄비가 자주 와요.", "The fourth month of the year.", "April rain helps the flowers."),
	("MARCH", "🌱", "3월. 학교가 시작돼요.", "The third month of the year.", "School starts in March."),
	("AUGUST", "🌻", "8월. 방학이 있는 달이에요.", "The eighth month of the year.", "August is our holiday month."),
	("JANUARY", "❄️", "1월. 한 해의 첫 달이에요.", "The first month of the year.", "January is cold and quiet."),
	("OCTOBER", "🍂", "10월. 잎이 물드는 달이에요.", "The tenth month of the year.", "October leaves turn gold."),
],
[
	("FEBRUARY", "⛄", "2월. 가장 짧은 달이에요.", "The shortest month of the year.", "February has only 28 days."),
	("NOVEMBER", "🌫️", "11월. 바람이 차가워져요.", "The eleventh month of the year.", "November mornings are misty."),
	("DECEMBER", "🎄", "12월. 한 해의 마지막 달이에요.", "The last month of the year.", "December ends the year."),
	("SEPTEMBER", "🌾", "9월. 열매를 거두는 달이에요.", "The ninth month of the year.", "September is harvest time."),
])

theme("WEEKDAY", "요일", "WEEKDAY", "GEAR", (0.06, 0.08, 0.10), (0.6, 0.9, 0.95), (0.8, 1.0, 1.0),
[
	("MONDAY", "1️⃣", "월요일. 한 주가 시작돼요.", "The first day of the work week.", "Monday always comes too fast."),
	("FRIDAY", "5️⃣", "금요일. 주말 바로 앞이에요.", "The last day before the weekend.", "Friday is my favorite day."),
	("SUNDAY", "☀️", "일요일. 쉬는 날이에요.", "The day of rest at the week's end.", "We stay home on Sunday."),
	("TUESDAY", "2️⃣", "화요일. 월요일 다음이에요.", "The day after Monday.", "Tuesday is a busy day."),
	("WEEKEND", "🛋️", "주말. 토요일과 일요일이에요.", "Saturday and Sunday together.", "The weekend went by fast."),
	("HOLIDAY", "🎉", "휴일. 일하지 않는 날이에요.", "A day when nobody works.", "Tomorrow is a holiday."),
	("THURSDAY", "4️⃣", "목요일. 금요일 하루 전이에요.", "The day before Friday.", "We meet every Thursday."),
	("SATURDAY", "6️⃣", "토요일. 주말의 첫날이에요.", "The first day of the weekend.", "Saturday morning is quiet."),
],
[
	("BIRTHDAY", "🎂", "생일. 태어난 날이에요.", "The day you were born.", "Her birthday is next week."),
	("SCHEDULE", "🗓️", "일정. 언제 무엇을 할지 적어요.", "A plan of what happens when.", "Check the schedule again."),
	("WEDNESDAY", "3️⃣", "수요일. 주의 가운데예요.", "The middle day of the week.", "Wednesday is halfway there."),
	("ANNIVERSARY", "💐", "기념일. 매년 돌아오는 특별한 날이에요.", "A day you remember every year.", "They celebrate their anniversary."),
])

theme("DIRECTION", "방향", "DIRECTION", "GEAR", (0.08, 0.07, 0.10), (0.75, 0.8, 1.0), (0.9, 0.9, 1.0),
[
	("UP", "⬆️", "위. 하늘 쪽이에요.", "Toward a higher place.", "Look up at the stars."),
	("TOP", "🔝", "맨 위. 가장 높은 곳이에요.", "The highest part of something.", "Write your name at the top."),
	("LEFT", "⬅️", "왼쪽. 오른쪽의 반대예요.", "The side opposite the right.", "Turn left at the corner."),
	("EAST", "🌅", "동쪽. 해가 뜨는 쪽이에요.", "The direction where the sun rises.", "The sun rises in the east."),
	("WEST", "🌇", "서쪽. 해가 지는 쪽이에요.", "The direction where the sun sets.", "The sun sets in the west."),
	("DOWN", "⬇️", "아래. 땅 쪽이에요.", "Toward a lower place.", "Climb down very slowly."),
	("NORTH", "🧭", "북쪽. 나침반이 가리키는 쪽이에요.", "The direction a compass points to.", "We walked north all morning."),
	("RIGHT", "➡️", "오른쪽. 왼쪽의 반대예요.", "The side opposite the left.", "The shop is on the right."),
],
[
	("SOUTH", "🗺️", "남쪽. 북쪽의 반대예요.", "The direction opposite north.", "Birds fly south in autumn."),
	("MIDDLE", "⏺️", "가운데. 양쪽에서 같은 거리예요.", "The point at the center.", "Sit in the middle row."),
	("FORWARD", "⏩", "앞으로. 나아가는 쪽이에요.", "Toward the front.", "Take one step forward."),
	("BACKWARD", "⏪", "뒤로. 물러나는 쪽이에요.", "Toward the back.", "He walked backward slowly."),
])

theme("NUMBER", "숫자", "NUMBER", "STAR", (0.06, 0.09, 0.09), (0.5, 1.0, 0.9), (0.7, 1.0, 0.95),
[
	("ONE", "1️⃣", "하나. 가장 작은 셈이에요.", "The number 1.", "I only need one pencil."),
	("TWO", "2️⃣", "둘. 하나에 하나를 더해요.", "The number 2.", "Two birds sit on the wire."),
	("SIX", "6️⃣", "여섯. 다섯보다 하나 많아요.", "The number 6.", "Six eggs are left."),
	("TEN", "🔟", "열. 손가락 수예요.", "The number 10.", "Count to ten and stop."),
	("FOUR", "4️⃣", "넷. 셋보다 하나 많아요.", "The number 4.", "A table has four legs."),
	("FIVE", "5️⃣", "다섯. 한 손의 손가락 수예요.", "The number 5.", "Five minutes is enough."),
	("NINE", "9️⃣", "아홉. 열보다 하나 적어요.", "The number 9.", "The train leaves at nine."),
	("THREE", "3️⃣", "셋. 둘보다 하나 많아요.", "The number 3.", "Three cats sleep together."),
],
[
	("SEVEN", "7️⃣", "일곱. 한 주의 날 수예요.", "The number 7.", "A week has seven days."),
	("EIGHT", "8️⃣", "여덟. 일곱보다 하나 많아요.", "The number 8.", "Eight players are ready."),
	("HUNDRED", "💯", "백. 열의 열 배예요.", "The number 100.", "A hundred people came."),
	("THOUSAND", "🔢", "천. 백의 열 배예요.", "The number 1000.", "A thousand stars filled the sky."),
])

theme("ART", "예술", "ART", "BLOB", (0.10, 0.06, 0.11), (1.0, 0.65, 1.0), (1.0, 0.85, 1.0),
[
	("INK", "🖋️", "잉크. 글씨나 그림을 그리는 물감이에요.", "Colored liquid used for writing.", "The ink spilled on my hand."),
	("CLAY", "🏺", "찰흙. 손으로 모양을 빚어요.", "Soft earth you shape with your hands.", "She shapes the wet clay."),
	("PAINT", "🎨", "물감. 색을 칠하는 것이에요.", "Colored liquid you spread on a surface.", "The paint is still wet."),
	("BRUSH", "🖌️", "붓. 물감을 칠하는 도구예요.", "A tool with hairs for painting.", "Dip the brush in water."),
	("EASEL", "🖼️", "이젤. 그림을 세워 두는 틀이에요.", "A stand that holds a painting.", "The easel stands by the window."),
	("CANVAS", "🖼️", "캔버스. 그림을 그리는 천이에요.", "Strong cloth that you paint on.", "The canvas is blank still."),
	("SKETCH", "✏️", "스케치. 대충 그린 그림이에요.", "A quick simple drawing.", "He made a fast sketch."),
	("GALLERY", "🏛️", "미술관. 그림을 걸어 두는 곳이에요.", "A place where art is shown.", "The gallery opens at ten."),
],
[
	("PALETTE", "🎨", "팔레트. 물감을 섞는 판이에요.", "A board for mixing colors.", "Her palette is full of blue."),
	("PORTRAIT", "🖼️", "초상화. 사람 얼굴을 그린 그림이에요.", "A picture of a person.", "The portrait looks so real."),
	("SCULPTURE", "🗿", "조각. 깎거나 빚어 만든 작품이에요.", "Art made by carving or shaping.", "The sculpture is made of stone."),
	("MASTERPIECE", "🌟", "명작. 아주 훌륭한 작품이에요.", "A work of outstanding quality.", "This painting is a masterpiece."),
])

theme("READING", "독서", "READING", "LEAF", (0.07, 0.08, 0.06), (0.7, 1.0, 0.7), (0.85, 1.0, 0.85),
[
	("PAGE", "📄", "쪽. 책의 한 면이에요.", "One side of a sheet in a book.", "Turn to the next page."),
	("POEM", "📜", "시. 짧고 아름다운 글이에요.", "A short piece of beautiful writing.", "She read the poem aloud."),
	("TALE", "📖", "이야기. 옛날부터 전해져요.", "A story, often an old one.", "Grandma told an old tale."),
	("NOVEL", "📕", "소설. 긴 이야기 책이에요.", "A long written story.", "This novel has 300 pages."),
	("TITLE", "🏷️", "제목. 책의 이름이에요.", "The name of a book or film.", "I forgot the title."),
	("COMIC", "📚", "만화. 그림으로 된 이야기예요.", "A story told with pictures.", "He reads one comic a day."),
	("LETTER", "✉️", "편지. 사람에게 써서 보내요.", "A written message you send.", "A letter came this morning."),
	("AUTHOR", "✍️", "작가. 책을 쓴 사람이에요.", "The person who wrote a book.", "The author signed my book."),
],
[
	("CHAPTER", "📖", "장. 책을 나눈 한 부분이에요.", "One part of a book.", "Finish this chapter tonight."),
	("MAGAZINE", "📰", "잡지. 정기적으로 나오는 책이에요.", "A thin book that comes out weekly.", "The magazine has new photos."),
	("DICTIONARY", "📔", "사전. 단어의 뜻을 찾아요.", "A book that explains words.", "Look it up in the dictionary."),
	("ENCYCLOPEDIA", "📚", "백과사전. 온갖 지식을 담은 책이에요.", "A book with facts about everything.", "The encyclopedia is very heavy."),
])

theme("COMPUTER", "컴퓨터", "COMPUTER", "GEAR", (0.05, 0.08, 0.11), (0.5, 0.9, 1.0), (0.7, 1.0, 1.0),
[
	("KEY", "🔑", "키. 눌러서 글자를 입력해요.", "A button you press to type.", "This key is stuck."),
	("FILE", "📁", "파일. 저장한 자료 하나예요.", "A saved set of information.", "Open the file again."),
	("DATA", "💾", "데이터. 저장된 정보예요.", "Information stored in a machine.", "All the data is safe."),
	("MOUSE", "🖱️", "마우스. 손으로 움직여 가리켜요.", "A device you move with your hand.", "Move the mouse slowly."),
	("SCREEN", "🖥️", "화면. 그림과 글자가 보여요.", "The flat part that shows images.", "The screen is too bright."),
	("LAPTOP", "💻", "노트북. 들고 다니는 컴퓨터예요.", "A computer you can carry.", "My laptop is very light."),
	("FOLDER", "📂", "폴더. 파일을 모아 두는 곳이에요.", "A place that holds files together.", "Put it in that folder."),
	("KEYBOARD", "⌨️", "키보드. 글자를 치는 판이에요.", "The board of keys you type on.", "The keyboard needs cleaning."),
],
[
	("INTERNET", "🌐", "인터넷. 온 세상 컴퓨터가 이어져요.", "The network that links computers.", "The internet is slow today."),
	("PASSWORD", "🔒", "비밀번호. 나만 아는 열쇠예요.", "A secret word that unlocks something.", "Never share your password."),
	("DOWNLOAD", "⬇️", "다운로드. 파일을 받아 와요.", "To copy a file to your device.", "The download is almost done."),
	("PROGRAMMER", "🧑‍💻", "프로그래머. 프로그램을 만드는 사람이에요.", "A person who writes software.", "The programmer fixed the bug."),
])

theme("PHONE", "통신", "PHONE", "PULSE", (0.07, 0.06, 0.11), (0.8, 0.7, 1.0), (0.9, 0.85, 1.0),
[
	("CALL", "📞", "전화. 목소리로 이야기해요.", "To speak to someone by phone.", "I will call you tonight."),
	("TEXT", "💬", "문자. 글로 보내는 짧은 말이에요.", "A short written message.", "Send me a text later."),
	("CHAT", "🗨️", "대화. 가볍게 주고받는 말이에요.", "A friendly informal talk.", "We chat every evening."),
	("PHONE", "📱", "휴대전화. 어디서나 연락해요.", "A device for talking far away.", "My phone is almost dead."),
	("EMAIL", "📧", "이메일. 인터넷으로 보내는 편지예요.", "A letter sent over the internet.", "Check your email now."),
	("SIGNAL", "📶", "신호. 전파가 닿는 세기예요.", "The strength of a wireless link.", "The signal is weak here."),
	("MESSAGE", "✉️", "메시지. 전하고 싶은 말이에요.", "Information sent to someone.", "She left a short message."),
	("CHARGER", "🔌", "충전기. 배터리를 채워요.", "A device that refills a battery.", "I forgot my charger."),
],
[
	("ANTENNA", "📡", "안테나. 전파를 받아요.", "A rod that catches radio waves.", "The antenna sits on the roof."),
	("WIRELESS", "🛜", "무선. 줄 없이 이어져요.", "Working without any wires.", "This speaker is wireless."),
	("BROADCAST", "📺", "방송. 여러 사람에게 보내요.", "A program sent to many people.", "The broadcast starts at six."),
	("NOTIFICATION", "🔔", "알림. 새 소식을 알려 줘요.", "A short alert on your device.", "A notification woke me up."),
])

theme("SAFETY", "안전", "SAFETY", "PULSE", (0.11, 0.07, 0.05), (1.0, 0.7, 0.35), (1.0, 0.85, 0.5),
[
	("EXIT", "🚪", "출구. 나가는 문이에요.", "The way out of a building.", "The exit is behind you."),
	("HELP", "🆘", "도움. 어려울 때 청해요.", "Aid given when someone needs it.", "Shout for help right away."),
	("ALARM", "🚨", "경보. 위험을 소리로 알려요.", "A loud sound that warns you.", "The alarm rang at dawn."),
	("GUARD", "🛡️", "경비. 지켜 주는 사람이에요.", "A person who protects a place.", "A guard stands at the gate."),
	("HELMET", "⛑️", "헬멧. 머리를 보호해요.", "A hard hat that protects your head.", "Always wear your helmet."),
	("ESCAPE", "🏃", "탈출. 위험에서 벗어나요.", "To get away from danger.", "They escape through the window."),
	("DANGER", "⚠️", "위험. 다칠 수 있어요.", "The chance of getting hurt.", "This sign means danger."),
	("WARNING", "📢", "경고. 미리 알려 주는 말이에요.", "A message that tells you of risk.", "Read the warning first."),
],
[
	("CAUTION", "🚧", "주의. 조심하라는 뜻이에요.", "Careful attention to avoid harm.", "Handle the glass with caution."),
	("ACCIDENT", "💥", "사고. 뜻하지 않게 생긴 일이에요.", "Something bad that happens by chance.", "The accident blocked the road."),
	("EMERGENCY", "🚑", "비상. 아주 급한 상황이에요.", "A sudden serious situation.", "Call this number in an emergency."),
	("EXTINGUISHER", "🧯", "소화기. 불을 끄는 통이에요.", "A device that puts out fire.", "The extinguisher hangs by the door."),
])

theme("PARTY", "축제", "PARTY", "STAR", (0.10, 0.06, 0.10), (1.0, 0.6, 0.9), (1.0, 0.8, 0.95),
[
	("GIFT", "🎁", "선물. 마음을 담아 줘요.", "Something you give to someone.", "Open your gift now."),
	("FLAG", "🚩", "깃발. 흔들며 응원해요.", "A piece of cloth on a pole.", "The flag waves in the wind."),
	("PRIZE", "🏆", "상. 잘한 사람에게 줘요.", "Something won for doing well.", "She won the first prize."),
	("CANDLE", "🕯️", "초. 불을 붙여 세워요.", "A stick of wax with a flame.", "Blow out every candle."),
	("RIBBON", "🎀", "리본. 예쁘게 묶어요.", "A narrow strip tied in a bow.", "Tie a red ribbon on it."),
	("PARADE", "🎏", "행렬. 줄지어 지나가요.", "A line of people moving through streets.", "The parade passes at noon."),
	("BALLOON", "🎈", "풍선. 공기를 넣어 띄워요.", "A bag of air or gas that floats.", "One balloon flew away."),
	("FIREWORK", "🎆", "불꽃. 하늘에서 터져요.", "A device that explodes in colors.", "The firework lit the sky."),
],
[
	("CARNIVAL", "🎠", "카니발. 큰 놀이 축제예요.", "A large public festival with rides.", "The carnival comes each spring."),
	("CONFETTI", "🎊", "색종이 조각. 뿌리며 축하해요.", "Small bits of paper thrown in joy.", "Confetti covers the floor."),
	("FESTIVAL", "🎪", "축제. 여러 사람이 모여 즐겨요.", "A time when people gather to celebrate.", "The festival lasts three days."),
	("CELEBRATION", "🎉", "축하. 기쁜 일을 함께 기려요.", "An event held for a happy reason.", "The celebration went late."),
])

theme("GARDEN", "정원", "GARDEN", "LEAF", (0.05, 0.10, 0.06), (0.55, 1.0, 0.5), (0.75, 1.0, 0.7),
[
	("POND", "🪷", "연못. 작고 얕은 물이에요.", "A small area of still water.", "Frogs live in the pond."),
	("SOIL", "🪴", "흙. 식물이 뿌리를 내려요.", "The earth where plants grow.", "The soil is dark and rich."),
	("HOSE", "🚿", "호스. 물을 뿌려요.", "A long tube that carries water.", "Roll up the garden hose."),
	("WEED", "🌿", "잡초. 원하지 않는 풀이에요.", "A plant growing where you do not want it.", "Pull out every weed."),
	("BENCH", "🪑", "벤치. 여럿이 앉는 의자예요.", "A long seat for two or more people.", "We rest on the bench."),
	("HEDGE", "🌳", "생울타리. 나무로 만든 담이에요.", "A wall made of bushes.", "The hedge needs cutting."),
	("GRAVEL", "🪨", "자갈. 작은 돌들이에요.", "Small stones on a path.", "The gravel crunches underfoot."),
	("SPROUT", "🌱", "새싹. 막 자라난 어린 잎이에요.", "A very young plant just starting.", "A green sprout appeared."),
],
[
	("TRELLIS", "🪴", "격자 지지대. 덩굴이 타고 올라가요.", "A frame that climbing plants grow on.", "Roses cover the trellis."),
	("WATERING", "💧", "물 주기. 식물에 물을 줘요.", "Giving water to plants.", "Watering takes ten minutes."),
	("GREENHOUSE", "🏡", "온실. 유리로 덮어 따뜻하게 해요.", "A glass building for growing plants.", "Tomatoes grow in the greenhouse."),
	("WHEELBARROW", "🛒", "손수레. 흙이나 짐을 옮겨요.", "A small cart you push by hand.", "The wheelbarrow is full of soil."),
])

theme("DINING", "식당", "DINING", "BLOB", (0.10, 0.08, 0.05), (1.0, 0.8, 0.45), (1.0, 0.9, 0.6),
[
	("TIP", "💵", "팁. 고마움으로 더 주는 돈이에요.", "Extra money given for good service.", "He left a small tip."),
	("MENU", "📋", "메뉴. 무엇을 파는지 적혀 있어요.", "A list of food you can order.", "Look at the menu first."),
	("ORDER", "📝", "주문. 무엇을 먹을지 말해요.", "To ask for food you want.", "May I order now?"),
	("STRAW", "🥤", "빨대. 음료를 빨아 마셔요.", "A thin tube for drinking.", "Use a paper straw."),
	("WAITER", "🧑‍🍳", "종업원. 음식을 가져다줘요.", "A person who serves food.", "The waiter brings the water."),
	("NAPKIN", "🧻", "냅킨. 입과 손을 닦아요.", "Paper or cloth for wiping your mouth.", "Fold the napkin neatly."),
	("RECEIPT", "🧾", "영수증. 낸 돈을 적어 줘요.", "A paper showing what you paid.", "Keep the receipt, please."),
	("SERVING", "🍽️", "1인분. 한 사람이 먹는 양이에요.", "The amount of food for one person.", "One serving is enough."),
],
[
	("TAKEOUT", "🥡", "포장. 싸서 가져가요.", "Food you carry away to eat.", "We ordered takeout tonight."),
	("LEFTOVER", "🍱", "남은 음식. 다 못 먹고 남겨요.", "Food that was not eaten.", "The leftover rice is cold."),
	("APPETIZER", "🥗", "전채. 본 음식 전에 먹어요.", "A small dish before the main food.", "The appetizer came fast."),
	("INGREDIENT", "🧂", "재료. 요리에 들어가는 것들이에요.", "One of the foods used in a dish.", "Salt is the last ingredient."),
])


# ============================================================
# 확장 4차분 — 기존 테마 심화 (심화 4 → 8)
#
# ⚠️ 심화 배열은 **글자 수 오름차순**이어야 하고, 첫 단어가 기본의 마지막보다 짧으면
#    층 경계가 거꾸로 간다. 뒤에 그냥 붙이면 둘 다 깨지므로 `deepen()` 이 넣고 **다시 정렬**한다.
# ⚠️ 그래서 추가 단어는 그 테마의 **기본 마지막 단어보다 길거나 같아야** 한다
#    (b5~b8 이므로 대체로 6글자 이상으로 골랐다).
# ============================================================


def deepen(tid, extra):
	for t in THEMES:
		if t["id"] == tid:
			t["advanced"].extend(extra)
			t["advanced"].sort(key=lambda tup: len(tup[0]))
			return
	raise SystemExit("deepen: 없는 테마 %s" % tid)


deepen("FOOD", [
	("PANCAKE", "🥞", "팬케이크. 납작하게 부친 빵이에요.", "A flat round cake fried in a pan.", "He flips the pancake high."),
	("PORRIDGE", "🥣", "죽. 곡물을 오래 끓여 만들어요.", "Soft food made by boiling grain.", "Warm porridge on a cold day."),
	("DUMPLING", "🥟", "만두. 반죽에 속을 넣어 쪄요.", "Dough wrapped around a filling.", "One dumpling is left."),
	("SPAGHETTI", "🍝", "스파게티. 길고 가는 면이에요.", "Long thin pasta served with sauce.", "The spaghetti smells wonderful."),
])
deepen("FRUIT", [
	("APRICOT", "🍑", "살구. 작고 주황색이에요.", "A small soft orange fruit.", "This apricot is very sweet."),
	("COCONUT", "🥥", "코코넛. 껍질이 딱딱해요.", "A large hard brown fruit with milk inside.", "We opened the coconut."),
	("MANDARIN", "🍊", "귤. 껍질이 잘 벗겨져요.", "A small orange that peels easily.", "Peel the mandarin for me."),
	("WATERMELON", "🍉", "수박. 크고 속이 붉어요.", "A big green fruit with red inside.", "The watermelon is cold and sweet."),
])
deepen("DRINK", [
	("BEVERAGE", "🥤", "음료. 마시는 것 전부예요.", "Any kind of drink.", "Choose one cold beverage."),
	("ESPRESSO", "☕", "에스프레소. 진한 커피예요.", "A small strong cup of coffee.", "One espresso wakes me up."),
	("MILKSHAKE", "🥛", "밀크셰이크. 우유를 갈아 만든 음료예요.", "A thick cold drink made with milk.", "The milkshake is too thick."),
	("REFRESHMENT", "🧊", "간식과 음료. 잠시 쉬며 먹어요.", "Food and drink taken during a break.", "Refreshment is served outside."),
])
deepen("FAMILY", [
	("NEPHEW", "👦", "조카. 형제자매의 아들이에요.", "The son of your brother or sister.", "My nephew turns five today."),
	("GRANDMA", "👵", "할머니. 부모의 어머니예요.", "The mother of your parent.", "Grandma tells the best stories."),
	("GRANDPA", "👴", "할아버지. 부모의 아버지예요.", "The father of your parent.", "Grandpa walks in the park."),
	("RELATIVE", "👨‍👩‍👧", "친척. 피가 이어진 사람이에요.", "A person in your family.", "Every relative came to dinner."),
])
deepen("HOUSE", [
	("GARAGE", "🚗", "차고. 차를 넣어 두는 곳이에요.", "A room where a car is kept.", "The bikes are in the garage."),
	("CEILING", "🏠", "천장. 방의 위쪽 면이에요.", "The top surface of a room.", "A lamp hangs from the ceiling."),
	("BALCONY", "🪟", "발코니. 밖으로 나온 좁은 마루예요.", "A small platform outside a window.", "We eat on the balcony."),
	("BASEMENT", "🪜", "지하실. 집의 아래층이에요.", "A room below the ground floor.", "The basement is cool and dark."),
])
deepen("SCHOOL", [
	("LESSON", "📚", "수업. 배우는 시간이에요.", "A period of learning.", "The lesson starts at nine."),
	("HOMEWORK", "📝", "숙제. 집에서 하는 공부예요.", "School work you do at home.", "Finish your homework first."),
	("PRINCIPAL", "🧑‍🏫", "교장. 학교를 이끄는 사람이에요.", "The person in charge of a school.", "The principal greets everyone."),
	("GYMNASIUM", "🏟️", "체육관. 운동하는 큰 방이에요.", "A large room for sports.", "We play inside the gymnasium."),
])
deepen("CLOTHES", [
	("POCKET", "👖", "주머니. 물건을 넣는 곳이에요.", "A small bag sewn into clothes.", "My pocket is empty."),
	("SANDALS", "👡", "샌들. 발등이 트인 신발이에요.", "Open shoes for warm weather.", "She wears blue sandals."),
	("RAINCOAT", "🧥", "비옷. 비를 막아 줘요.", "A coat that keeps rain off.", "Take your raincoat today."),
	("TURTLENECK", "🧣", "목폴라. 목까지 올라와요.", "A sweater with a high collar.", "This turtleneck is warm."),
])
deepen("SPORT", [
	("ARCHERY", "🏹", "궁도. 활로 과녁을 맞혀요.", "The sport of shooting arrows.", "Archery needs a steady hand."),
	("CYCLING", "🚴", "자전거 경기. 자전거로 달려요.", "The sport of riding a bicycle.", "Cycling uphill is hard."),
	("MARATHON", "🏅", "마라톤. 아주 먼 거리를 달려요.", "A very long running race.", "She finished the marathon."),
	("BADMINTON", "🏸", "배드민턴. 셔틀콕을 주고받아요.", "A game played with rackets and a shuttle.", "We play badminton after school."),
])
deepen("MUSIC", [
	("RHYTHM", "🎵", "리듬. 소리의 규칙적인 흐름이에요.", "A regular pattern of sound.", "Clap to the rhythm."),
	("CONCERT", "🎤", "연주회. 여러 사람 앞에서 연주해요.", "A public musical performance.", "The concert starts at seven."),
	("SYMPHONY", "🎼", "교향곡. 관현악단이 연주하는 큰 곡이에요.", "A long piece for a full orchestra.", "The symphony filled the hall."),
	("INSTRUMENT", "🎻", "악기. 소리를 내는 도구예요.", "An object used to make music.", "Pick one instrument to learn."),
])
deepen("JOB", [
	("WRITER", "✍️", "작가. 글을 쓰는 사람이에요.", "A person whose work is writing.", "The writer works at night."),
	("LAWYER", "⚖️", "변호사. 법을 다루는 사람이에요.", "A person trained in law.", "The lawyer read the contract."),
	("MECHANIC", "🔧", "정비사. 기계를 고치는 사람이에요.", "A person who repairs machines.", "The mechanic fixed my bike."),
	("ARCHITECT", "📐", "건축가. 건물을 설계해요.", "A person who designs buildings.", "The architect drew the plan."),
])
deepen("CITY", [
	("STREET", "🛣️", "거리. 건물 사이의 길이에요.", "A road in a town with buildings.", "The street is quiet at dawn."),
	("TRAFFIC", "🚦", "교통. 길을 다니는 차들이에요.", "Vehicles moving along a road.", "Morning traffic is heavy."),
	("SIDEWALK", "🚶", "인도. 사람이 걷는 길이에요.", "The path beside a road for walking.", "Stay on the sidewalk."),
	("SKYSCRAPER", "🏙️", "고층 건물. 하늘까지 솟아요.", "A very tall city building.", "The skyscraper touches the clouds."),
])
deepen("VEHICLE", [
	("SCOOTER", "🛵", "스쿠터. 작은 오토바이예요.", "A small motorbike with a step.", "He rides a red scooter."),
	("TRAILER", "🚚", "트레일러. 뒤에 달려 끌려가요.", "A container pulled behind a vehicle.", "The trailer carries wood."),
	("AMBULANCE", "🚑", "구급차. 환자를 급히 옮겨요.", "A vehicle that carries sick people.", "The ambulance moved fast."),
	("MOTORCYCLE", "🏍️", "오토바이. 두 바퀴로 빠르게 달려요.", "A fast vehicle with two wheels.", "The motorcycle roared past."),
])
deepen("WEATHER", [
	("DRIZZLE", "🌧️", "가랑비. 아주 가늘게 내려요.", "Very light rain.", "A soft drizzle began."),
	("TEMPEST", "🌪️", "폭풍. 바람이 몹시 거세요.", "A violent storm with strong wind.", "The tempest broke the fence."),
	("HUMIDITY", "💦", "습도. 공기 속 물기의 양이에요.", "The amount of water in the air.", "The humidity is very high."),
	("HAILSTONE", "🧊", "우박. 얼음덩이가 떨어져요.", "A ball of ice that falls from clouds.", "One hailstone hit the roof."),
])
deepen("TIME", [
	("DECADE", "📅", "십 년. 열 해예요.", "A period of ten years.", "A decade passed quickly."),
	("CENTURY", "🕰️", "백 년. 백 해예요.", "A period of one hundred years.", "This wall is a century old."),
	("MIDNIGHT", "🌃", "자정. 밤 열두 시예요.", "Twelve o'clock at night.", "The train leaves at midnight."),
	("AFTERNOON", "🌤️", "오후. 낮이 지난 뒤예요.", "The time between noon and evening.", "We meet this afternoon."),
])
deepen("SHAPE", [
	("DIAMOND", "💎", "다이아몬드 모양. 네 변이 기울어요.", "A shape like a tilted square.", "Draw a small diamond."),
	("HEXAGON", "⬢", "육각형. 변이 여섯이에요.", "A shape with six straight sides.", "A honeycomb is a hexagon."),
	("PYRAMID", "🔺", "피라미드. 밑이 네모고 위가 뾰족해요.", "A solid with a square base and a point.", "The pyramid casts a shadow."),
	("PENTAGON", "🔷", "오각형. 변이 다섯이에요.", "A shape with five straight sides.", "Count the pentagon's sides."),
])
deepen("EMOTION", [
	("BORING", "😐", "지루한. 재미가 없어요.", "Not interesting at all.", "The long wait was boring."),
	("JEALOUS", "😒", "질투하는. 남이 가진 걸 부러워해요.", "Unhappy because someone has something.", "He felt a little jealous."),
	("GRATEFUL", "🙏", "고마운. 마음이 따뜻해져요.", "Feeling thankful for something.", "I am grateful for your help."),
	("CONFIDENT", "😎", "자신 있는. 잘할 수 있다고 믿어요.", "Sure that you can do something.", "She looks very confident."),
])
deepen("SEA", [
	("ANCHOR", "⚓", "닻. 배를 붙잡아 둬요.", "A heavy hook that holds a ship.", "Drop the anchor here."),
	("LAGOON", "🏝️", "호수 같은 바다. 얕고 잔잔해요.", "A shallow area of sea near land.", "The lagoon is warm and calm."),
	("SEASHELL", "🐚", "조개껍데기. 모래밭에서 주워요.", "The hard cover of a sea animal.", "I found a pink seashell."),
	("SUBMARINE", "🛥️", "잠수함. 물속을 다녀요.", "A ship that travels under water.", "The submarine went deeper."),
])
deepen("INSECT", [
	("CICADA", "🦗", "매미. 여름에 크게 울어요.", "An insect that sings loudly in summer.", "One cicada sang all day."),
	("TERMITE", "🐜", "흰개미. 나무를 파먹어요.", "An insect that eats wood.", "Termites damaged the beam."),
	("MOSQUITO", "🦟", "모기. 피를 빨고 가려워요.", "A small insect that bites and itches.", "A mosquito bit my arm."),
	("CATERPILLAR", "🐛", "애벌레. 나중에 나비가 돼요.", "A young insect that becomes a butterfly.", "The caterpillar eats a leaf."),
])
deepen("PLANT", [
	("THISTLE", "🌾", "엉겅퀴. 가시가 있는 풀이에요.", "A wild plant with sharp leaves.", "A thistle grew by the wall."),
	("SEEDLING", "🌱", "모종. 어린 식물이에요.", "A very young plant grown from seed.", "Water the seedling gently."),
	("POLLINATE", "🐝", "수분하다. 꽃가루를 옮겨 줘요.", "To carry pollen from flower to flower.", "Bees pollinate the field."),
	("CHLOROPHYLL", "🍃", "엽록소. 잎을 초록으로 만들어요.", "The green matter inside leaves.", "Chlorophyll makes leaves green."),
])
deepen("HEALTH", [
	("SURGERY", "🏥", "수술. 몸을 열어 고쳐요.", "Medical treatment that opens the body.", "The surgery went well."),
	("ALLERGY", "🤧", "알레르기. 어떤 것에 몸이 반응해요.", "A bad reaction to something harmless.", "He has a dust allergy."),
	("EXERCISE", "🏃", "운동. 몸을 움직여 튼튼해져요.", "Physical activity that keeps you fit.", "Daily exercise helps a lot."),
	("NUTRITION", "🥗", "영양. 몸에 필요한 것들이에요.", "The food your body needs to grow.", "Good nutrition starts young."),
])
deepen("TRAVEL", [
	("BACKPACK", "🎒", "배낭. 등에 메는 가방이에요.", "A bag you carry on your back.", "My backpack holds everything."),
	("ITINERARY", "🗒️", "여행 일정. 어디를 언제 갈지 적어요.", "A plan of a journey.", "Print the itinerary out."),
	("SIGHTSEEING", "🏛️", "관광. 볼거리를 찾아 다녀요.", "Visiting places of interest.", "We spent the day sightseeing."),
	("DESTINATION", "📍", "목적지. 가려는 곳이에요.", "The place you are going to.", "Our destination is still far."),
])
deepen("AIRPORT", [
	("SECURITY", "🛂", "보안. 위험한 것을 막아요.", "Measures that keep people safe.", "Security takes ten minutes."),
	("AIRCRAFT", "✈️", "항공기. 하늘을 나는 기계예요.", "Any machine that flies.", "The aircraft is ready now."),
	("TURBULENCE", "🌪️", "난기류. 비행기가 흔들려요.", "Rough air that shakes a plane.", "Turbulence lasted a minute."),
	("INTERNATIONAL", "🌐", "국제의. 여러 나라 사이의 것이에요.", "Between two or more countries.", "This is an international flight."),
])
deepen("KITCHEN", [
	("SPATULA", "🍳", "뒤집개. 음식을 뒤집어요.", "A flat tool for turning food.", "Use the spatula for eggs."),
	("TOASTER", "🍞", "토스터. 빵을 구워요.", "A machine that browns bread.", "The toaster popped up."),
	("STRAINER", "🍜", "체. 물을 걸러 내요.", "A tool that separates water from food.", "Pour it through the strainer."),
	("DISHWASHER", "🧽", "식기세척기. 그릇을 씻어 줘요.", "A machine that washes dishes.", "The dishwasher is full."),
])
deepen("VEGETABLE", [
	("RADISH", "🥗", "무. 뿌리를 먹어요.", "A crisp root with a sharp taste.", "Slice the radish thin."),
	("BROCCOLI", "🥦", "브로콜리. 초록 꽃송이 모양이에요.", "A green vegetable shaped like a tree.", "Steam the broccoli lightly."),
	("ZUCCHINI", "🥒", "애호박. 길고 초록색이에요.", "A long green summer squash.", "Grill the zucchini slices."),
	("ASPARAGUS", "🌿", "아스파라거스. 가늘고 긴 줄기예요.", "A thin green stalk you eat.", "Asparagus grows in spring."),
])
deepen("BIRD", [
	("FEATHER", "🪶", "깃털. 새의 몸을 덮어요.", "One of the light parts covering a bird.", "A white feather drifted down."),
	("SPARROW", "🐦", "참새. 작고 흔한 새예요.", "A small common brown bird.", "A sparrow hops on the path."),
	("OSTRICH", "🦤", "타조. 가장 큰 새인데 못 날아요.", "The largest bird, which cannot fly.", "The ostrich runs very fast."),
	("NIGHTINGALE", "🎶", "나이팅게일. 밤에 아름답게 울어요.", "A small bird that sings at night.", "A nightingale sang outside."),
])

deepen("TREE", [
	("CANOPY", "🌳", "나무 위 덮개. 잎이 하늘을 가려요.", "The leafy top layer of a forest.", "Light filters through the canopy."),
	("TIMBER", "🪵", "목재. 집을 짓는 나무예요.", "Wood prepared for building.", "The timber is stacked outside."),
	("SAPLING", "🌱", "어린 나무. 아직 얇아요.", "A young thin tree.", "We planted one sapling."),
	("EVERGREEN", "🌲", "상록수. 겨울에도 잎이 있어요.", "A tree that keeps its leaves all year.", "The evergreen stays green in snow."),
])
deepen("FLOWER", [
	("BOUQUET", "💐", "꽃다발. 여러 꽃을 묶었어요.", "A bunch of flowers tied together.", "He carries a small bouquet."),
	("GARLAND", "🌺", "꽃목걸이. 꽃을 이어 만들어요.", "A ring of flowers worn or hung.", "A garland hangs on the door."),
	("FLORIST", "💐", "꽃집 주인. 꽃을 팔아요.", "A person who sells flowers.", "The florist opens early."),
	("WILDFLOWER", "🌾", "들꽃. 저절로 피는 꽃이에요.", "A flower that grows without planting.", "Wildflowers cover the hill."),
])
deepen("TOOL", [
	("CHISEL", "🪚", "끌. 나무나 돌을 깎아요.", "A sharp tool for cutting wood or stone.", "He taps the chisel gently."),
	("PLIERS", "🔧", "펜치. 잡고 구부려요.", "A tool for holding and bending.", "Grip it with the pliers."),
	("SANDPAPER", "🧱", "사포. 거친 면을 문질러 매끈하게 해요.", "Rough paper used to smooth surfaces.", "Rub it with sandpaper."),
	("WORKBENCH", "🪑", "작업대. 위에서 일하는 튼튼한 상이에요.", "A strong table for working on.", "Tools cover the workbench."),
])
deepen("MONEY", [
	("PROFIT", "📈", "이익. 벌어서 남은 돈이에요.", "Money left after costs.", "The shop made a small profit."),
	("SALARY", "💵", "월급. 일해서 매달 받는 돈이에요.", "Money paid regularly for work.", "His salary arrives on Friday."),
	("EXCHANGE", "💱", "환전. 돈을 다른 돈으로 바꿔요.", "Trading one money for another.", "Check the exchange rate."),
	("CURRENCY", "💰", "통화. 나라마다 쓰는 돈이에요.", "The money used in a country.", "Each country has its currency."),
])
deepen("FARM", [
	("PLOUGH", "🚜", "쟁기. 흙을 갈아 뒤집어요.", "A tool that turns over soil.", "The plough cuts deep lines."),
	("MANURE", "🌱", "거름. 흙을 기름지게 해요.", "Animal waste used to feed soil.", "Manure helps the crops grow."),
	("LIVESTOCK", "🐄", "가축. 기르는 동물들이에요.", "Farm animals kept for use.", "The livestock stay inside."),
	("IRRIGATION", "💧", "관개. 밭에 물을 끌어와요.", "Bringing water to dry fields.", "Irrigation saved the harvest."),
])
deepen("DESSERT", [
	("SORBET", "🍧", "셔벗. 얼린 과일 디저트예요.", "A frozen sweet made from fruit.", "Lemon sorbet is refreshing."),
	("CUSTARD", "🍮", "커스터드. 달걀과 우유로 만들어요.", "A soft sweet made of eggs and milk.", "The custard is silky smooth."),
	("MERINGUE", "🍥", "머랭. 달걀 흰자를 부풀려 구워요.", "A light sweet made from egg whites.", "The meringue crumbles easily."),
	("CHEESECAKE", "🍰", "치즈케이크. 치즈로 만든 케이크예요.", "A rich cake made with soft cheese.", "One slice of cheesecake, please."),
])
deepen("ACTION", [
	("BUILD", "🧱", "짓다. 쌓아서 만들어요.", "To make something by putting parts together.", "They build a small wall."),
	("SHARE", "🤝", "나누다. 같이 써요.", "To give part of something to others.", "Share the cookies with him."),
	("GATHER", "🧺", "모으다. 한곳에 담아요.", "To bring things into one place.", "We gather apples in baskets."),
	("PRACTICE", "🔁", "연습하다. 반복해서 익혀요.", "To do something again to get better.", "Practice makes it easy."),
])
deepen("MOTION", [
	("WANDER", "🚶", "거닐다. 목적 없이 돌아다녀요.", "To walk slowly with no clear aim.", "We wander through the market."),
	("SWERVE", "↩️", "급히 틀다. 방향을 확 바꿔요.", "To turn suddenly to one side.", "The car swerved to the left."),
	("PLUNGE", "🌊", "곤두박질치다. 아래로 세게 떨어져요.", "To fall or dive quickly downward.", "The bird plunged into the sea."),
	("WHIRLWIND", "🌪️", "회오리. 빙빙 도는 바람이에요.", "A column of fast spinning wind.", "A whirlwind lifted the leaves."),
])
deepen("SENSE", [
	("HEARING", "👂", "청력. 소리를 듣는 능력이에요.", "The ability to hear sounds.", "His hearing is very sharp."),
	("PERFUME", "🌸", "향수. 좋은 냄새가 나는 물이에요.", "A liquid with a pleasant smell.", "Her perfume smells of roses."),
	("EYESIGHT", "👁️", "시력. 보는 능력이에요.", "The ability to see.", "Reading in the dark hurts eyesight."),
	("SENSATION", "✨", "감각. 몸으로 느끼는 것이에요.", "A feeling in your body.", "A cold sensation ran up my arm."),
])
deepen("SIZE", [
	("MEDIUM", "📏", "중간 크기. 크지도 작지도 않아요.", "Neither large nor small.", "I take a medium shirt."),
	("SLENDER", "🌱", "가느다란. 얇고 길어요.", "Thin in an attractive way.", "The slender stem bent over."),
	("COLOSSAL", "🗿", "거대한. 어마어마하게 커요.", "Extremely large in size.", "A colossal statue stood there."),
	("MICROSCOPIC", "🔬", "아주 미세한. 현미경으로 봐야 보여요.", "So small you need a microscope.", "Microscopic dust floats in air."),
])
deepen("FLAVOR", [
	("SMOKED", "🔥", "훈제한. 연기로 향을 냈어요.", "Given flavor by smoke.", "The smoked fish tastes strong."),
	("BUTTERY", "🧈", "버터 맛의. 부드럽고 진해요.", "Tasting rich like butter.", "The crust is light and buttery."),
	("AROMATIC", "🌿", "향이 좋은. 냄새가 은은해요.", "Having a pleasant strong smell.", "Aromatic herbs fill the pot."),
	("REFRESHING", "🥤", "상쾌한. 시원하게 기운이 나요.", "Making you feel cool and awake.", "Cold water is refreshing."),
])
deepen("TEMPERATURE", [
	("THAWING", "💧", "녹는. 얼었던 것이 풀려요.", "Becoming soft after being frozen.", "The thawing ice drips slowly."),
	("TROPICAL", "🌴", "열대의. 늘 덥고 습해요.", "Belonging to the hot wet places.", "Tropical nights are warm."),
	("SWELTERING", "🥵", "찌는 듯한. 숨이 막힐 만큼 더워요.", "Uncomfortably hot and damp.", "It was a sweltering day."),
	("THERMOSTAT", "🌡️", "온도 조절기. 온도를 맞춰 줘요.", "A device that controls temperature.", "Turn the thermostat down."),
])
deepen("SPEED", [
	("SWIFTLY", "💨", "재빠르게. 아주 빨리요.", "In a very quick way.", "She moved swiftly aside."),
	("MOMENTUM", "🎯", "기세. 움직임이 이어지는 힘이에요.", "The force of something already moving.", "The ball gains momentum."),
	("VELOCITY", "📈", "속도. 얼마나 빠른지예요.", "The speed of something in one direction.", "Measure the wind velocity."),
	("LEISURELY", "🐌", "느긋한. 서두르지 않아요.", "Slow and relaxed.", "We took a leisurely walk."),
])
deepen("STATE", [
	("RUSTY", "🔩", "녹슨. 오래되어 붉게 변했어요.", "Covered with rust from age.", "The rusty gate squeaks."),
	("SPARE", "🧰", "여분의. 남겨 둔 것이에요.", "Kept in case it is needed.", "Keep a spare key outside."),
	("DAMAGED", "🔧", "손상된. 일부가 망가졌어요.", "Harmed but not fully broken.", "The damaged box still closes."),
	("USELESS", "🚮", "쓸모없는. 아무 도움이 안 돼요.", "Of no use at all.", "This useless pen is dry."),
])
deepen("CALENDAR", [
	("EQUINOX", "🌗", "춘분·추분. 낮과 밤이 같아요.", "A day when day and night are equal.", "The equinox comes in March."),
	("QUARTER", "📆", "분기. 한 해를 넷으로 나눠요.", "One of the four parts of a year.", "Sales rose this quarter."),
	("SEMESTER", "🏫", "학기. 학교의 한 기간이에요.", "Half of a school year.", "The semester ends in June."),
	("MILLENNIUM", "🕰️", "천 년. 아주 긴 시간이에요.", "A period of one thousand years.", "A millennium is very long."),
])
deepen("WEEKDAY", [
	("WORKWEEK", "💼", "근무 주. 일하는 날들이에요.", "The days of the week people work.", "The workweek feels long."),
	("OVERTIME", "⏰", "초과 근무. 정해진 시간을 넘겨 일해요.", "Extra time worked beyond normal hours.", "He worked overtime again."),
	("DEADLINE", "⏳", "기한. 그때까지 끝내야 해요.", "The time by which work must be done.", "The deadline is Friday noon."),
	("APPOINTMENT", "📌", "약속. 만날 시간을 정해요.", "An arranged time to meet.", "I have a dental appointment."),
])
deepen("DIRECTION", [
	("CORNER", "📐", "모퉁이. 두 면이 만나는 곳이에요.", "The place where two sides meet.", "Wait at the next corner."),
	("DIAGONAL", "↗️", "대각선의. 모서리에서 모서리로 가요.", "Going from one corner to another.", "Draw a diagonal line."),
	("OPPOSITE", "↔️", "반대의. 정확히 마주 봐요.", "Directly across from something.", "They sat on opposite sides."),
	("HORIZONTAL", "➖", "수평의. 바닥과 나란해요.", "Flat and level, side to side.", "Keep the shelf horizontal."),
])
deepen("NUMBER", [
	("TWELVE", "🕛", "열둘. 한 해의 달 수예요.", "The number 12.", "A year has twelve months."),
	("TWENTY", "🔢", "스물. 열의 두 배예요.", "The number 20.", "Twenty chairs are ready."),
	("MILLION", "💫", "백만. 아주 큰 수예요.", "The number 1,000,000.", "A million stars shone above."),
	("FRACTION", "➗", "분수. 전체의 일부를 나타내요.", "A part of a whole number.", "Half is a simple fraction."),
])
deepen("ART", [
	("DRAWING", "🖍️", "그림. 선으로 그린 것이에요.", "A picture made with lines.", "Her drawing is very neat."),
	("PATTERN", "🔷", "무늬. 규칙적으로 반복돼요.", "A repeated arrangement of shapes.", "The pattern repeats every inch."),
	("EXHIBITION", "🏛️", "전시회. 작품을 늘어놓고 보여줘요.", "A public show of art.", "The exhibition ends Sunday."),
	("WATERCOLOR", "🎨", "수채화. 물에 개어 그려요.", "Paint mixed with water.", "Watercolor dries very fast."),
])
deepen("READING", [
	("PREFACE", "📖", "서문. 책의 첫머리 글이에요.", "A short note at the start of a book.", "Read the preface first."),
	("SUMMARY", "📝", "요약. 짧게 줄인 내용이에요.", "A short account of the main points.", "Write a one-page summary."),
	("BOOKMARK", "🔖", "책갈피. 읽던 쪽을 표시해요.", "Something that marks your page.", "My bookmark fell out."),
	("BIOGRAPHY", "📗", "전기. 어떤 사람의 삶을 쓴 책이에요.", "The story of a person's life.", "This biography is fascinating."),
])
deepen("COMPUTER", [
	("SOFTWARE", "💿", "소프트웨어. 컴퓨터를 움직이는 프로그램이에요.", "Programs that run on a computer.", "Update the software tonight."),
	("HARDWARE", "🖥️", "하드웨어. 만질 수 있는 부품이에요.", "The physical parts of a computer.", "The hardware is brand new."),
	("ALGORITHM", "🧮", "알고리듬. 문제를 푸는 순서예요.", "A set of steps that solves a problem.", "This algorithm sorts numbers."),
	("APPLICATION", "📲", "응용 프로그램. 특정 일을 해 줘요.", "A program made for one purpose.", "Install the new application."),
])
deepen("PHONE", [
	("ROAMING", "🌍", "로밍. 다른 나라에서 쓰는 거예요.", "Using your phone in another country.", "Roaming costs extra money."),
	("CONTACTS", "📇", "연락처. 이름과 번호를 모아 둬요.", "The list of people you can call.", "Add me to your contacts."),
	("VOICEMAIL", "📼", "음성 메시지. 못 받으면 남겨 둬요.", "A recorded spoken message.", "She left a long voicemail."),
	("SMARTPHONE", "📱", "스마트폰. 인터넷이 되는 전화예요.", "A phone that runs programs.", "My smartphone needs charging."),
])
deepen("SAFETY", [
	("LIFEBOAT", "🛶", "구명보트. 위험할 때 타고 나가요.", "A small boat used to save people.", "The lifeboat hangs on the side."),
	("SEATBELT", "💺", "안전띠. 몸을 좌석에 붙잡아 줘요.", "A strap that holds you in a seat.", "Buckle your seatbelt now."),
	("PRECAUTION", "🚧", "예방 조치. 미리 막아 둬요.", "An action taken to prevent harm.", "Wearing gloves is a precaution."),
	("PROTECTION", "🛡️", "보호. 해를 막아 줘요.", "The act of keeping something safe.", "Sunscreen gives protection."),
])
deepen("PARTY", [
	("STREAMER", "🎊", "장식 띠. 길게 늘어뜨려요.", "A long strip of paper for decoration.", "Streamers hang from the ceiling."),
	("INVITATION", "💌", "초대장. 오라고 보내는 편지예요.", "A written request to come.", "The invitation arrived today."),
	("DECORATION", "🎀", "장식. 예쁘게 꾸미는 것이에요.", "Something added to make a place pretty.", "The decorations look lovely."),
	("ENTERTAINMENT", "🎭", "여흥. 즐겁게 해 주는 것이에요.", "Things that amuse people.", "Live music is the entertainment."),
])
deepen("GARDEN", [
	("SHEARS", "✂️", "큰 가위. 가지를 자를 때 써요.", "Large scissors for cutting plants.", "Sharpen the garden shears."),
	("COMPOST", "🍂", "퇴비. 썩힌 것으로 흙을 살려요.", "Rotted plants used to feed soil.", "Add compost to the bed."),
	("FLOWERBED", "🌷", "화단. 꽃을 심어 둔 자리예요.", "A patch of ground planted with flowers.", "The flowerbed is full of color."),
	("LANDSCAPE", "🏞️", "경관. 눈에 보이는 넓은 풍경이에요.", "A wide view of an area of land.", "The landscape changes in autumn."),
])
deepen("DINING", [
	("CUISINE", "🍲", "요리. 어떤 지역의 음식 방식이에요.", "A style of cooking from a place.", "Thai cuisine is very fragrant."),
	("PORTION", "🍽️", "몫. 한 사람 앞의 양이에요.", "An amount of food for one person.", "The portion is quite large."),
	("GRATUITY", "💵", "봉사료. 고마움으로 더 내는 돈이에요.", "Money added for good service.", "A gratuity is already included."),
	("SPECIALTY", "🌟", "특선. 그 집이 가장 잘하는 요리예요.", "The dish a place is famous for.", "Try the chef's specialty."),
])


# ============================================================
# 확장 5차분 — 새 테마 10개 (120단어). 목표 1000개 달성분.
# ============================================================

theme("BATHROOM", "욕실", "BATHROOM", "BLOB", (0.05, 0.09, 0.11), (0.5, 0.9, 1.0), (0.7, 1.0, 1.0),
[
	("TUB", "🛁", "욕조. 물을 받아 몸을 담가요.", "A large container you sit in to wash.", "Fill the tub with warm water."),
	("SOAP", "🧼", "비누. 문지르면 거품이 나요.", "Something you rub on to get clean.", "The soap smells like lemon."),
	("SINK", "🚰", "세면대. 손을 씻는 곳이에요.", "A bowl with taps for washing.", "The sink is full of bubbles."),
	("COMB", "🪮", "빗. 머리를 정리해요.", "A tool with teeth for your hair.", "Run the comb through slowly."),
	("TOWEL", "🧺", "수건. 물기를 닦아요.", "Cloth used to dry yourself.", "Hang the towel to dry."),
	("DRAIN", "🕳️", "배수구. 물이 빠져나가요.", "The hole where water flows out.", "The drain is blocked again."),
	("FAUCET", "🚿", "수도꼭지. 돌리면 물이 나와요.", "The tap that water comes from.", "Turn the faucet off tightly."),
	("SHAMPOO", "🧴", "샴푸. 머리를 감을 때 써요.", "Liquid soap for washing hair.", "The shampoo bottle is empty."),
],
[
	("BATHROBE", "🧖", "목욕 가운. 씻고 나서 걸쳐요.", "A loose robe worn after a bath.", "He wraps up in a bathrobe."),
	("TOOTHPASTE", "🦷", "치약. 이를 닦을 때 짜요.", "Paste used for cleaning teeth.", "Squeeze a little toothpaste."),
	("TOOTHBRUSH", "🪥", "치솔. 이를 문질러 닦아요.", "A small brush for your teeth.", "My toothbrush is worn out."),
	("VENTILATION", "💨", "환기. 공기를 바꿔 줘요.", "Letting fresh air move through.", "Good ventilation stops mold."),
])

theme("BEDROOM", "침실", "BEDROOM", "BLOB", (0.08, 0.06, 0.11), (0.75, 0.7, 1.0), (0.9, 0.85, 1.0),
[
	("RUG", "🧶", "깔개. 바닥에 펴 두어요.", "A small thick cloth for the floor.", "A soft rug lies by the bed."),
	("SHEET", "🛏️", "침대보. 매트리스를 덮어요.", "A flat cloth you sleep on.", "Change the sheet today."),
	("DRAWER", "🗄️", "서랍. 밀고 당겨 여는 칸이에요.", "A box that slides in and out.", "My socks are in the drawer."),
	("CLOSET", "🚪", "붙박이장. 옷을 걸어 두어요.", "A small room for storing clothes.", "The closet door squeaks."),
	("HANGER", "🧷", "옷걸이. 옷을 걸어 둬요.", "A frame for hanging clothes.", "Use a wooden hanger."),
	("CURTAIN", "🪟", "커튼. 창을 가려요.", "Cloth that covers a window.", "Draw the curtain at night."),
	("MATTRESS", "🛏️", "매트리스. 침대 위 두꺼운 깔개예요.", "The thick pad you sleep on.", "This mattress is very firm."),
	("WARDROBE", "🚪", "옷장. 옷을 넣어 두는 큰 가구예요.", "A tall cupboard for clothes.", "The wardrobe smells of cedar."),
],
[
	("BEDSPREAD", "🛏️", "침대 덮개. 침대 전체를 덮어요.", "A decorative cover for a bed.", "The bedspread is pale blue."),
	("HEADBOARD", "🪵", "머리판. 침대 머리 쪽 판이에요.", "The board at the head of a bed.", "She leans on the headboard."),
	("NIGHTSTAND", "🕯️", "침대 옆 탁자. 손닿는 곳에 둬요.", "A small table beside a bed.", "A lamp sits on the nightstand."),
	("CHANDELIER", "💡", "샹들리에. 여러 등이 달린 조명이에요.", "A hanging light with many bulbs.", "The chandelier sparkles above."),
])

theme("POSTAL", "우편", "POSTAL", "GEAR", (0.09, 0.07, 0.06), (1.0, 0.75, 0.5), (1.0, 0.9, 0.7),
[
	("STAMP", "📮", "우표. 편지에 붙여요.", "A small paper you stick on mail.", "Stick the stamp on straight."),
	("PARCEL", "📦", "소포. 싸서 보내는 짐이에요.", "A wrapped package sent by mail.", "A heavy parcel arrived."),
	("SENDER", "📤", "보내는 사람. 우편을 부친 사람이에요.", "The person who sends something.", "The sender left no name."),
	("ADDRESS", "🏠", "주소. 어디로 갈지 적어요.", "Where a person or place is.", "Write the address clearly."),
	("MAILBOX", "📬", "우편함. 편지가 들어오는 곳이에요.", "A box where mail is left.", "The mailbox is already full."),
	("COURIER", "🚚", "택배 기사. 물건을 배달해요.", "A person who delivers packages.", "The courier rang the bell."),
	("ENVELOPE", "✉️", "봉투. 편지를 넣어요.", "A paper cover for a letter.", "Seal the envelope tightly."),
	("POSTCARD", "🖼️", "그림엽서. 짧은 안부를 적어요.", "A card with a picture sent by mail.", "A postcard came from Rome."),
],
[
	("DELIVERY", "🚚", "배달. 물건을 가져다줘요.", "Bringing goods to a place.", "Delivery takes two days."),
	("SHIPMENT", "📦", "발송 화물. 함께 보내는 짐이에요.", "Goods sent together.", "The shipment left this morning."),
	("RECIPIENT", "🧍", "받는 사람. 우편을 받을 사람이에요.", "The person who receives something.", "The recipient signed for it."),
	("REGISTERED", "📋", "등기의. 받은 기록을 남겨요.", "Recorded so it cannot be lost.", "Send it as registered mail."),
])

theme("MINERAL", "광물", "MINERAL", "GEAR", (0.07, 0.07, 0.09), (0.8, 0.85, 1.0), (0.95, 0.95, 1.0),
[
	("IRON", "⛓️", "철. 단단하고 무거운 금속이에요.", "A hard heavy grey metal.", "The gate is made of iron."),
	("COAL", "🪨", "석탄. 태우면 열이 나요.", "A black rock that burns for heat.", "Coal burns with a red glow."),
	("SALT", "🧂", "소금. 짠맛을 내는 결정이에요.", "White crystals that taste salty.", "Salt comes from the sea."),
	("COPPER", "🟠", "구리. 붉은빛 금속이에요.", "A reddish metal that carries heat.", "Copper wires bend easily."),
	("MARBLE", "🪨", "대리석. 매끈하고 무늬가 있어요.", "A smooth stone with swirling lines.", "The floor is white marble."),
	("QUARTZ", "💎", "석영. 맑고 단단한 광물이에요.", "A hard clear mineral.", "A quartz crystal caught the light."),
	("GRANITE", "🗿", "화강암. 아주 단단한 돌이에요.", "A very hard speckled rock.", "The steps are cut from granite."),
	("OBSIDIAN", "🌑", "흑요석. 유리처럼 검고 날카로워요.", "Black volcanic glass.", "Obsidian breaks into sharp edges."),
],
[
	("AMETHYST", "💜", "자수정. 보라색 보석이에요.", "A purple precious stone.", "The amethyst glows softly."),
	("SAPPHIRE", "💙", "사파이어. 깊은 파란 보석이에요.", "A deep blue precious stone.", "Her ring holds one sapphire."),
	("LIMESTONE", "🧱", "석회암. 물에 잘 녹는 돌이에요.", "A soft rock that water can dissolve.", "Caves form in limestone."),
	("TURQUOISE", "🩵", "터키석. 하늘빛 푸른 돌이에요.", "A blue green stone.", "The turquoise beads are old."),
])

theme("MOUNTAIN", "산", "MOUNTAIN", "LEAF", (0.06, 0.08, 0.07), (0.6, 0.95, 0.8), (0.8, 1.0, 0.9),
[
	("PEAK", "⛰️", "봉우리. 산의 가장 높은 곳이에요.", "The pointed top of a mountain.", "Snow covers the peak."),
	("CAVE", "🕳️", "굴. 산속 빈 공간이에요.", "A hollow space inside rock.", "The cave is dark and cold."),
	("CLIFF", "🧗", "절벽. 깎아지른 벽이에요.", "A steep face of rock.", "Do not stand near the cliff."),
	("RIDGE", "🏔️", "능선. 산꼭대기를 잇는 선이에요.", "A long narrow top of high land.", "We walked along the ridge."),
	("SLOPE", "🎿", "경사. 기울어진 면이에요.", "Ground that goes up or down.", "The slope is steep here."),
	("VALLEY", "🏞️", "골짜기. 산 사이 낮은 땅이에요.", "Low land between two hills.", "Fog fills the valley."),
	("SUMMIT", "🗻", "정상. 끝까지 오른 지점이에요.", "The very top of a mountain.", "They reached the summit at dawn."),
	("BOULDER", "🪨", "큰 바위. 굴러온 돌덩이예요.", "A very large loose rock.", "A boulder blocks the trail."),
],
[
	("PLATEAU", "🏜️", "고원. 높고 평평한 땅이에요.", "High flat land.", "The plateau stretches for miles."),
	("ALTITUDE", "📈", "고도. 얼마나 높은지예요.", "Height above sea level.", "The air thins at altitude."),
	("AVALANCHE", "🏔️", "눈사태. 눈이 쏟아져 내려요.", "A mass of snow sliding down.", "An avalanche closed the road."),
	("MOUNTAINEER", "🧗", "등산가. 산을 오르는 사람이에요.", "A person who climbs mountains.", "The mountaineer packs light."),
])

theme("LAUNDRY", "세탁", "LAUNDRY", "PULSE", (0.06, 0.08, 0.10), (0.6, 0.9, 1.0), (0.8, 1.0, 1.0),
[
	("SOAK", "💧", "담그다. 물에 오래 두어요.", "To leave something in water.", "Soak the shirt overnight."),
	("STAIN", "🟤", "얼룩. 지워지지 않는 흔적이에요.", "A mark that is hard to remove.", "The coffee stain spread."),
	("DRYER", "🌀", "건조기. 젖은 옷을 말려요.", "A machine that dries clothes.", "The dryer is still running."),
	("STEAM", "♨️", "증기. 뜨거운 물에서 올라와요.", "Hot vapor from boiling water.", "Steam rises from the iron."),
	("FABRIC", "🧵", "천. 옷을 만드는 재료예요.", "Cloth used to make clothes.", "This fabric feels soft."),
	("BASKET", "🧺", "바구니. 빨래를 담아요.", "A container with an open top.", "The basket is full of socks."),
	("IRONING", "🔥", "다림질. 주름을 펴요.", "Pressing clothes to remove wrinkles.", "Ironing takes a long time."),
	("WASHING", "🫧", "세탁. 물로 빨아요.", "Cleaning clothes with water.", "The washing is nearly done."),
],
[
	("LAUNDRY", "🧺", "세탁물. 빨아야 할 옷들이에요.", "Clothes that need washing.", "The laundry piled up again."),
	("SOFTENER", "🧴", "섬유유연제. 천을 부드럽게 해요.", "Liquid that makes fabric soft.", "Add softener at the end."),
	("DETERGENT", "🧼", "세제. 더러움을 씻어 내요.", "A soap used for cleaning clothes.", "Measure the detergent carefully."),
	("CLOTHESLINE", "🪢", "빨랫줄. 옷을 걸어 말려요.", "A rope for hanging wet clothes.", "Shirts flap on the clothesline."),
])

theme("BAKERY", "제빵", "BAKERY", "BLOB", (0.10, 0.08, 0.05), (1.0, 0.8, 0.45), (1.0, 0.9, 0.65),
[
	("OVEN", "🔥", "오븐. 안에서 구워요.", "A closed box that bakes food.", "The oven is already hot."),
	("DOUGH", "🥟", "반죽. 밀가루에 물을 섞어요.", "A soft mix of flour and water.", "Knead the dough for ten minutes."),
	("YEAST", "🫙", "이스트. 반죽을 부풀려요.", "Something that makes dough rise.", "Yeast makes the bread rise."),
	("FLOUR", "🌾", "밀가루. 곡물을 갈아 만들어요.", "Powder made from ground grain.", "Flour dusts the whole table."),
	("CRUST", "🥖", "겉껍질. 빵의 바깥이에요.", "The hard outside of bread.", "The crust cracks when cut."),
	("BAGEL", "🥯", "베이글. 가운데 구멍이 있어요.", "A ring of chewy bread.", "Toast the bagel lightly."),
	("MUFFIN", "🧁", "머핀. 작고 폭신한 빵이에요.", "A small round soft cake.", "A warm muffin for breakfast."),
	("BAGUETTE", "🥖", "바게트. 길고 딱딱한 빵이에요.", "A long thin loaf of bread.", "Break the baguette in half."),
],
[
	("CROISSANT", "🥐", "크루아상. 결이 겹겹인 빵이에요.", "A crescent roll with flaky layers.", "The croissant flakes everywhere."),
	("SOURDOUGH", "🍞", "사워도우. 살짝 신맛이 나요.", "Bread with a slightly sour taste.", "Sourdough keeps for days."),
	("CONFECTION", "🍬", "과자류. 달게 만든 것들이에요.", "A sweet food made with sugar.", "Each confection is wrapped."),
	("GINGERBREAD", "🍪", "진저브레드. 생강을 넣어 구워요.", "A spiced cake made with ginger.", "We build a gingerbread house."),
])

theme("SHOPPING", "쇼핑", "SHOPPING", "STAR", (0.09, 0.06, 0.09), (1.0, 0.7, 0.95), (1.0, 0.85, 1.0),
[
	("CART", "🛒", "카트. 물건을 담아 밀어요.", "A wheeled basket you push.", "The cart is already full."),
	("SALE", "🏷️", "할인 판매. 값을 내려 팔아요.", "A time when prices are lower.", "The winter sale starts today."),
	("AISLE", "🏬", "통로. 진열대 사이 길이에요.", "A passage between shelves.", "Milk is in aisle three."),
	("QUEUE", "🚶", "줄. 차례를 기다려요.", "A line of people waiting.", "The queue moves slowly."),
	("COUPON", "🎟️", "쿠폰. 값을 깎아 주는 표예요.", "A ticket that lowers a price.", "Use the coupon before Friday."),
	("CASHIER", "🧑‍💼", "계산원. 돈을 받는 사람이에요.", "A person who takes payment.", "The cashier smiled at me."),
	("TROLLEY", "🛒", "손수레. 짐을 실어 옮겨요.", "A small cart for carrying goods.", "Push the trolley this way."),
	("BARGAIN", "💰", "싼 물건. 값에 비해 좋아요.", "Something bought cheaply.", "This coat was a real bargain."),
],
[
	("CHECKOUT", "🧾", "계산대. 돈을 내는 곳이에요.", "The place where you pay.", "Meet me at the checkout."),
	("BOUTIQUE", "👗", "부티크. 작고 멋진 옷집이에요.", "A small shop selling stylish clothes.", "The boutique closes at eight."),
	("WAREHOUSE", "🏭", "창고. 물건을 쌓아 두는 큰 건물이에요.", "A large building for storing goods.", "The warehouse is nearly empty."),
	("SUPERMARKET", "🏪", "슈퍼마켓. 온갖 것을 파는 큰 가게예요.", "A large shop selling food and goods.", "The supermarket opens early."),
])

theme("FISHING", "낚시", "FISHING", "PAW", (0.05, 0.08, 0.11), (0.5, 0.85, 1.0), (0.7, 0.95, 1.0),
[
	("NET", "🕸️", "그물. 물고기를 걸러 잡아요.", "A mesh used to catch fish.", "Pull the net in slowly."),
	("BAIT", "🪱", "미끼. 물고기를 꾀어요.", "Food used to attract fish.", "Put fresh bait on the hook."),
	("HOOK", "🪝", "낚싯바늘. 구부러져 걸려요.", "A curved piece that catches fish.", "The hook caught my sleeve."),
	("REEL", "🎣", "릴. 줄을 감는 장치예요.", "A wheel that winds the line.", "Turn the reel steadily."),
	("POLE", "🎣", "낚싯대. 길고 가늘어요.", "A long thin rod for fishing.", "He leans the pole on a rock."),
	("TACKLE", "🧰", "낚시 도구. 한 벌로 갖춰요.", "The equipment used for fishing.", "His tackle box is heavy."),
	("HARBOR", "⚓", "항구. 배가 머무는 곳이에요.", "A safe place where boats stay.", "Boats rest in the harbor."),
	("SINKER", "🪨", "추. 줄을 물속으로 끌어내려요.", "A weight that pulls the line down.", "Add one more sinker."),
],
[
	("TROLLING", "🚤", "끌낚시. 배로 끌면서 잡아요.", "Fishing by dragging a line from a boat.", "Trolling works well at dawn."),
	("FISHERMAN", "🧑‍🌾", "어부. 고기를 잡는 사람이에요.", "A person who catches fish.", "The fisherman mends his net."),
	("FRESHWATER", "💧", "담수. 소금기 없는 물이에요.", "Water that is not salty.", "Carp live in freshwater."),
	("AQUACULTURE", "🐟", "양식. 물에서 길러 키워요.", "Raising fish in ponds or tanks.", "Aquaculture feeds many people."),
])

theme("SEASON", "계절", "SEASON", "LEAF", (0.07, 0.09, 0.08), (0.65, 1.0, 0.75), (0.85, 1.0, 0.9),
[
	("SPRING", "🌸", "봄. 꽃이 피는 계절이에요.", "The season when plants start to grow.", "Spring arrives with warm rain."),
	("SUMMER", "☀️", "여름. 가장 더운 계절이에요.", "The hottest season of the year.", "Summer days feel endless."),
	("AUTUMN", "🍂", "가을. 잎이 물드는 계절이에요.", "The season when leaves fall.", "Autumn turns the hills gold."),
	("WINTER", "❄️", "겨울. 가장 추운 계절이에요.", "The coldest season of the year.", "Winter closes the mountain road."),
	("SNOWMAN", "⛄", "눈사람. 눈을 뭉쳐 만들어요.", "A figure built out of snow.", "Our snowman has a carrot nose."),
	("MONSOON", "🌧️", "장마. 오래 비가 내려요.", "A season of very heavy rain.", "The monsoon floods the fields."),
	("SUNSHINE", "🌞", "햇살. 따뜻한 햇빛이에요.", "Light and warmth from the sun.", "Sunshine fills the kitchen."),
	("BLIZZARD", "🌨️", "눈보라. 눈과 바람이 몰아쳐요.", "A storm with snow and strong wind.", "The blizzard lasted all night."),
],
[
	("HEATWAVE", "🥵", "열파. 며칠 내내 몹시 더워요.", "A long spell of very hot weather.", "The heatwave broke at last."),
	("SNOWFLAKE", "❄️", "눈송이. 하나하나 무늬가 달라요.", "One small crystal of falling snow.", "A snowflake landed on my glove."),
	("HIBERNATE", "🐻", "동면하다. 겨울잠을 자요.", "To sleep through the winter.", "Bears hibernate in deep caves."),
	("MIGRATION", "🦆", "이동. 계절에 따라 옮겨 가요.", "Moving to another place each season.", "Autumn begins the migration."),
])
