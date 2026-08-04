/* ========================================
   NeonBlaster — Homepage Scripts
   별 배경 애니메이션 + 인터랙션
   ======================================== */

(function () {
	'use strict';

	/* ===== 1. ANIMATED STARFIELD ===== */
	const canvas = document.getElementById('starfield');
	const ctx = canvas.getContext('2d');

	let stars = [];
	let shootingStars = [];
	let W = 0;
	let H = 0;

	const STAR_COLORS = [
		'rgba(0, 240, 255, ',    // neon cyan
		'rgba(255, 0, 128, ',    // neon pink
		'rgba(180, 0, 255, ',    // neon purple
		'rgba(255, 255, 255, ',  // white
	];

	function resize() {
		W = canvas.width = window.innerWidth;
		H = canvas.height = window.innerHeight;
		initStars();
	}

	function initStars() {
		stars = [];
		const count = Math.floor((W * H) / 8000);
		for (let i = 0; i < count; i++) {
			stars.push({
				x: Math.random() * W,
				y: Math.random() * H,
				r: Math.random() * 1.5 + 0.3,
				speed: Math.random() * 0.3 + 0.05,
				color: STAR_COLORS[Math.floor(Math.random() * STAR_COLORS.length)],
				twinkle: Math.random() * Math.PI * 2,
				twinkleSpeed: Math.random() * 0.03 + 0.01,
			});
		}
	}

	function spawnShootingStar() {
		if (Math.random() > 0.003) return;
		shootingStars.push({
			x: Math.random() * W,
			y: Math.random() * H * 0.5,
			vx: (Math.random() - 0.5) * 8 + 4,
			vy: Math.random() * 3 + 2,
			life: 1.0,
			trail: [],
		});
	}

	function drawStars() {
		ctx.clearRect(0, 0, W, H);

		// 배경 그라데이션
		const grad = ctx.createRadialGradient(W / 2, H / 2, 0, W / 2, H / 2, Math.max(W, H));
		grad.addColorStop(0, 'rgba(15, 10, 40, 0.3)');
		grad.addColorStop(1, 'rgba(5, 5, 16, 0)');
		ctx.fillStyle = grad;
		ctx.fillRect(0, 0, W, H);

		// 별
		for (const s of stars) {
			s.twinkle += s.twinkleSpeed;
			s.y += s.speed;
			if (s.y > H) {
				s.y = 0;
				s.x = Math.random() * W;
			}
			const alpha = 0.3 + Math.sin(s.twinkle) * 0.3 + 0.3;
			ctx.beginPath();
			ctx.arc(s.x, s.y, s.r, 0, Math.PI * 2);
			ctx.fillStyle = s.color + alpha + ')';
			ctx.shadowBlur = s.r * 4;
			ctx.shadowColor = s.color + '0.5)';
			ctx.fill();
		}
		ctx.shadowBlur = 0;

		// 유성
		spawnShootingStar();
		for (let i = shootingStars.length - 1; i >= 0; i--) {
			const ss = shootingStars[i];
			ss.trail.push({ x: ss.x, y: ss.y });
			if (ss.trail.length > 15) ss.trail.shift();
			ss.x += ss.vx;
			ss.y += ss.vy;
			ss.life -= 0.015;

			// 트레일 그리기
			for (let j = 0; j < ss.trail.length; j++) {
				const t = ss.trail[j];
				const a = (j / ss.trail.length) * ss.life * 0.8;
				ctx.beginPath();
				ctx.arc(t.x, t.y, 1.5, 0, Math.PI * 2);
				ctx.fillStyle = 'rgba(0, 240, 255, ' + a + ')';
				ctx.fill();
			}
			// 유성 머리
			ctx.beginPath();
			ctx.arc(ss.x, ss.y, 2, 0, Math.PI * 2);
			ctx.fillStyle = 'rgba(0, 240, 255, ' + ss.life + ')';
			ctx.shadowBlur = 10;
			ctx.shadowColor = 'rgba(0, 240, 255, 0.8)';
			ctx.fill();
			ctx.shadowBlur = 0;

			if (ss.life <= 0 || ss.x > W || ss.y > H) {
				shootingStars.splice(i, 1);
			}
		}

		requestAnimationFrame(drawStars);
	}

	window.addEventListener('resize', resize);
	resize();
	drawStars();

	/* ===== 2. SCROLL REVEAL ===== */
	const observer = new IntersectionObserver(
		function (entries) {
			entries.forEach(function (entry) {
				if (entry.isIntersecting) {
					entry.target.classList.add('revealed');
					observer.unobserve(entry.target);
				}
			});
		},
		{ threshold: 0.15 }
	);

	// Add reveal class and observe
	const revealTargets = document.querySelectorAll(
		'.feature-card, .enemy-card, .powerup-item, .step, .tech-item'
	);
	revealTargets.forEach(function (el) {
		el.style.opacity = '0';
		el.style.transform = 'translateY(30px)';
		el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
		observer.observe(el);
	});

	// Create a style tag for the revealed state
	const revealStyle = document.createElement('style');
	revealStyle.textContent =
		'.revealed { opacity: 1 !important; transform: translateY(0) !important; }';
	document.head.appendChild(revealStyle);

	/* ===== 3. NAV BACKGROUND ON SCROLL ===== */
	const nav = document.querySelector('.nav');
	window.addEventListener('scroll', function () {
		if (window.scrollY > 50) {
			nav.style.background = 'rgba(5, 5, 16, 0.95)';
		} else {
			nav.style.background = 'rgba(10, 10, 26, 0.85)';
		}
	});

	/* ===== 4. MOCKUP GAME ANIMATION ===== */
	const playArea = document.querySelector('.mockup__play-area');
	if (playArea) {
		// 주기적으로 총알 추가
		setInterval(function () {
			const bullet = document.createElement('div');
			bullet.className = 'entity entity--bullet';
			bullet.style.left = '48%';
			bullet.style.top = '70%';
			playArea.appendChild(bullet);
			setTimeout(function () {
				bullet.remove();
			}, 800);
		}, 300);

		// 주기적으로 적 이동
		const enemies = playArea.querySelectorAll('.entity--enemy');
		enemies.forEach(function (enemy, i) {
			const baseTop = parseFloat(enemy.style.top);
			const baseLeft = parseFloat(enemy.style.left);
			let phase = i * 0.5;
			setInterval(function () {
				phase += 0.02;
				enemy.style.top = baseTop + Math.sin(phase) * 3 + '%';
				enemy.style.left = baseLeft + Math.cos(phase) * 2 + '%';
			}, 50);
		});

		// 점수 카운트업
		const scoreEl = document.querySelector('.hud__score');
		if (scoreEl) {
			let score = 1240;
			setInterval(function () {
				score += Math.floor(Math.random() * 50 + 10);
				scoreEl.textContent = 'SCORE: ' + String(score).padStart(5, '0');
			}, 2000);
		}
	}

	/* ===== 5. POWERUP CLICK EFFECT ===== */
	const powerups = document.querySelectorAll('.powerup-item');
	powerups.forEach(function (pu) {
		pu.addEventListener('click', function () {
			pu.style.animation = 'none';
			requestAnimationFrame(function () {
				pu.style.animation = 'pulse-burst 0.4s ease';
			});
			setTimeout(function () {
				pu.style.animation = '';
			}, 400);
		});
	});

	// pulse-burst 키프레임 추가
	const burstStyle = document.createElement('style');
	burstStyle.textContent =
		'@keyframes pulse-burst { 0% { transform: scale(1); } 50% { transform: scale(1.2); } 100% { transform: scale(1); } }';
	document.head.appendChild(burstStyle);

	/* ===== 6. GLITCH INTENSITY RANDOMIZER ===== */
	const glitches = document.querySelectorAll('.glitch');
	setInterval(function () {
		glitches.forEach(function (el) {
			if (Math.random() > 0.7) {
				el.style.textShadow =
					'0 0 ' +
					Math.random() * 30 +
					'px rgba(0, 240, 255, 0.8), 0 0 ' +
					Math.random() * 60 +
					'px rgba(0, 240, 255, 0.4)';
			}
		});
	}, 2000);

	/* ===== 7. SMOOTH SCROLL OFFSET ===== */
	document.querySelectorAll('a[href^="#"]').forEach(function (anchor) {
		anchor.addEventListener('click', function (e) {
			const target = document.querySelector(this.getAttribute('href'));
			if (target) {
				e.preventDefault();
				const offset = 80;
				const top = target.getBoundingClientRect().top + window.scrollY - offset;
				window.scrollTo({ top: top, behavior: 'smooth' });
			}
		});
	});

	/* ===== 8. LEARNING COURSES SYSTEM ===== */
	const galleryGrid = document.getElementById('galleryGrid');
	const galleryEmpty = document.getElementById('galleryEmpty');
	const wordSearch = document.getElementById('wordSearch');
	const courseGrid = document.getElementById('courseGrid');
	const courseInfo = document.getElementById('courseInfo');
	const courseInfoIcon = document.getElementById('courseInfoIcon');
	const courseInfoName = document.getElementById('courseInfoName');
	const courseInfoDesc = document.getElementById('courseInfoDesc');
	const courseProgressBar = document.getElementById('courseProgressBar');
	const courseProgressText = document.getElementById('courseProgressText');
	const courseBack = document.getElementById('courseBack');
	const courseControls = document.getElementById('courseControls');
	const levelBtns = document.querySelectorAll('.level-btn');

	let currentCourse = null;   // null = 전체 코스 목록, "SPACE" 등 = 특정 코스
	let currentLevel = 0;       // 0 = 전체, 1/2/3 = 레벨
	let learnedWords = {};      // localStorage에서 로드한 학습 완료 단어

	// 학습 진행도 로드/저장
	function loadProgress() {
		try {
			const saved = localStorage.getItem('neonblaster_learned');
			learnedWords = saved ? JSON.parse(saved) : {};
		} catch (e) {
			learnedWords = {};
		}
	}

	function saveProgress() {
		try {
			localStorage.setItem('neonblaster_learned', JSON.stringify(learnedWords));
		} catch (e) {}
	}

	function markLearned(word) {
		learnedWords[word] = true;
		saveProgress();
	}

	// 코스별 단어 개수 계산
	function getWordsForCourse(category) {
		return Object.entries(WORD_GALLERY).filter(function (entry) {
			return entry[1].category === category;
		});
	}

	function getLearnedCountForCourse(category) {
		return getWordsForCourse(category).filter(function (entry) {
			return learnedWords[entry[0]];
		}).length;
	}

	// 코스 카드 목록 렌더링
	function renderCourseGrid() {
		if (!courseGrid) return;
		courseGrid.innerHTML = '';
		galleryGrid.innerHTML = '';
		courseInfo.style.display = 'none';
		courseControls.style.display = 'none';

		// COURSE_INFO를 order 순으로 정렬
		const categories = Object.keys(COURSE_INFO).sort(function (a, b) {
			return COURSE_INFO[a].order - COURSE_INFO[b].order;
		});

		categories.forEach(function (cat) {
			const info = COURSE_INFO[cat];
			const wordCount = getWordsForCourse(cat).length;
			const learnedCount = getLearnedCountForCourse(cat);
			const pct = wordCount > 0 ? Math.round((learnedCount / wordCount) * 100) : 0;

			const card = document.createElement('div');
			card.className = 'course-card';
			card.innerHTML =
				'<span class="course-card__icon">' + info.icon + '</span>' +
				'<div class="course-card__name">' + cat + '</div>' +
				'<div class="course-card__ko">' + info.ko + '</div>' +
				'<div class="course-card__desc">' + info.desc + '</div>' +
				'<span class="course-card__count">' + wordCount + ' 단어</span>' +
				'<div class="course-card__progress-mini">' +
					'<div class="course-card__progress-mini-fill" style="width:' + pct + '%"></div>' +
				'</div>';

			card.addEventListener('click', function () {
				openCourse(cat);
			});
			courseGrid.appendChild(card);
		});
	}

	// 특정 코스 열기: 해당 카테고리 단어들을 렌더링
	function openCourse(category) {
		currentCourse = category;
		const info = COURSE_INFO[category];

		// 코스 정보 표시
		courseGrid.innerHTML = '';
		courseInfo.style.display = 'block';
		courseControls.style.display = 'flex';

		courseInfoIcon.textContent = info.icon;
		courseInfoName.textContent = category + ' — ' + info.ko;
		courseInfoDesc.textContent = info.desc;

		renderCourseWords();
	}

	// 현재 코스의 단어 카드 렌더링 (레벨 필터 + 검색 적용)
	function renderCourseWords() {
		if (!currentCourse) return;
		galleryGrid.innerHTML = '';

		const info = COURSE_INFO[currentCourse];
		const searchTerm = (wordSearch.value || '').toUpperCase().trim();

		// 레벨/검색으로 필터링
		const words = getWordsForCourse(currentCourse).filter(function (entry) {
			const data = entry[1];
			if (currentLevel > 0 && difficultyToLevel(data.difficulty) !== currentLevel) return false;
			if (searchTerm && entry[0].indexOf(searchTerm) === -1) return false;
			return true;
		});

		// 난이도 순 정렬 (EASY → NORMAL → HARD)
		words.sort(function (a, b) {
			return difficultyToLevel(a[1].difficulty) - difficultyToLevel(b[1].difficulty);
		});

		let count = 0;
		words.forEach(function (entry) {
			const word = entry[0];
			const data = entry[1];
			const level = difficultyToLevel(data.difficulty);
			const levelInfo = LEVEL_INFO[level];

			count++;
			const card = document.createElement('div');
			card.className = 'gallery-card' + (learnedWords[word] ? ' gallery-card--learned' : '');
			card.style.setProperty('--card-color', data.color);
			card.style.setProperty('--card-glow', data.color + '55');
			card.innerHTML =
				'<div class="gallery-card__level" style="color:' + levelInfo.color + '">' + levelInfo.stars + '</div>' +
				'<div class="gallery-card__icon">' + data.emoji + '</div>' +
				'<div class="gallery-card__word">' + word + '</div>' +
				'<div class="gallery-card__cat">' + data.category + '</div>' +
				'<div class="gallery-card__diff" data-d="' + data.difficulty + '">' + data.difficulty + '</div>';
			card.addEventListener('click', function () {
				openModal(word, data);
			});
			galleryGrid.appendChild(card);
		});

		// 빈 결과 표시
		if (galleryEmpty) {
			galleryEmpty.style.display = count === 0 ? 'block' : 'none';
		}

		// 진행도 바 업데이트
		updateProgressBar();
	}

	// 진행도 바 업데이트
	function updateProgressBar() {
		if (!currentCourse) return;
		const total = getWordsForCourse(currentCourse).length;
		const learned = getLearnedCountForCourse(currentCourse);
		const pct = total > 0 ? Math.round((learned / total) * 100) : 0;

		// 진행도 바 채우기 (::after width 제어를 위해 별도 요소 사용)
		courseProgressBar.style.position = 'relative';
		let fillEl = courseProgressBar.querySelector('.course-progress__fill');
		if (!fillEl) {
			fillEl = document.createElement('div');
			fillEl.className = 'course-progress__fill';
			fillEl.style.cssText = 'height:100%;background:linear-gradient(90deg,var(--neon-cyan),var(--neon-green));border-radius:4px;transition:width 0.5s ease;';
			courseProgressBar.appendChild(fillEl);
		}
		fillEl.style.width = pct + '%';

		courseProgressText.textContent = learned + '/' + total;
	}

	// 뒤로 가기
	if (courseBack) {
		courseBack.addEventListener('click', function () {
			currentCourse = null;
			wordSearch.value = '';
			currentLevel = 0;
			levelBtns.forEach(function (b) { b.classList.remove('active'); });
			levelBtns[0].classList.add('active'); // "전체"
			renderCourseGrid();
		});
	}

	// 레벨 필터 버튼
	levelBtns.forEach(function (btn) {
		btn.addEventListener('click', function () {
			levelBtns.forEach(function (b) { b.classList.remove('active'); });
			btn.classList.add('active');
			currentLevel = parseInt(btn.dataset.level);
			renderCourseWords();
		});
	});

	// 검색
	if (wordSearch) {
		wordSearch.addEventListener('input', function () {
			if (currentCourse) renderCourseWords();
		});
	}

	/* ===== 9. WORD DETAIL MODAL + SPEAK ===== */
	const modal = document.getElementById('wordModal');
	const modalIcon = document.getElementById('modalIcon');
	const modalWord = document.getElementById('modalWord');
	const modalCategory = document.getElementById('modalCategory');
	const modalDifficulty = document.getElementById('modalDifficulty');
	const modalSpelling = document.getElementById('modalSpelling');
	const modalKo = document.getElementById('modalKo');
	const modalEn = document.getElementById('modalEn');
	const modalClose = document.getElementById('modalClose');
	const modalSpeak = document.getElementById('modalSpeak');

	let currentWord = '';

	function openModal(word, data) {
		if (!modal) return;
		currentWord = word;

		// 학습 완료 표시
		markLearned(word);

		modalIcon.textContent = data.emoji;
		modalIcon.style.filter = 'drop-shadow(0 0 20px ' + data.color + ')';
		modalWord.textContent = word;
		modalWord.style.color = data.color;
		modalWord.style.textShadow = '0 0 20px ' + data.color;
		modalCategory.textContent = data.category;
		modalDifficulty.textContent = data.difficulty;
		modalDifficulty.dataset.d = data.difficulty;
		modalKo.textContent = data.ko;
		modalEn.textContent = data.en;

		// 스펠링 애니메이션
		modalSpelling.innerHTML = '';
		const letters = word.split('');
		letters.forEach(function (ch, i) {
			const span = document.createElement('span');
			span.className = 'spell-letter';
			span.textContent = ch;
			span.style.borderColor = data.color;
			span.style.color = data.color;
			modalSpelling.appendChild(span);
			setTimeout(function () {
				span.classList.add('show');
			}, i * 120);
		});

		// 모달 테두리 색상
		modal.querySelector('.modal').style.borderColor = data.color;
		modal.querySelector('.modal').style.boxShadow = '0 0 60px ' + data.color + '55';

		modal.classList.add('active');
	}

	function closeModal() {
		modal.classList.remove('active');
		if (modalSpeak) modalSpeak.classList.remove('speaking');
	}

	// 발음 듣기 (고품질 로컬 m4a 파일 + Web Speech API fallback)
	let audioPlayer = null;

	if (modalSpeak) {
		modalSpeak.addEventListener('click', function () {
			if (!currentWord) return;

			modalSpeak.classList.add('speaking');

			// 1차: 고품질 로컬 m4a 파일 재생
			const lower = currentWord.toLowerCase();
			const audioUrl = 'audio/' + lower + '.m4a';

			if (audioPlayer) {
				audioPlayer.pause();
				audioPlayer.currentTime = 0;
			}
			audioPlayer = new Audio(audioUrl);

			audioPlayer.onended = function () {
				modalSpeak.classList.remove('speaking');
			};
			audioPlayer.onerror = function () {
				// 2차: 로컬 파일 실패 시 Web Speech API fallback
				modalSpeak.classList.remove('speaking');
				if ('speechSynthesis' in window) {
					window.speechSynthesis.cancel();
					const utterance = new SpeechSynthesisUtterance(currentWord);
					utterance.lang = 'en-US';
					utterance.rate = 0.8;
					utterance.pitch = 1.0;
					modalSpeak.classList.add('speaking');
					utterance.onend = function () { modalSpeak.classList.remove('speaking'); };
					utterance.onerror = function () { modalSpeak.classList.remove('speaking'); };
					window.speechSynthesis.speak(utterance);
				} else {
					alert('죄송합니다. 이 브라우저는 음성 재생을 지원하지 않습니다.');
				}
			};

			audioPlayer.play().catch(function () {
				// autoplay 정책 등으로 실패 시 fallback
				modalSpeak.classList.remove('speaking');
				if ('speechSynthesis' in window) {
					window.speechSynthesis.cancel();
					const utterance = new SpeechSynthesisUtterance(currentWord);
					utterance.lang = 'en-US';
					utterance.rate = 0.8;
					modalSpeak.classList.add('speaking');
					utterance.onend = function () { modalSpeak.classList.remove('speaking'); };
					utterance.onerror = function () { modalSpeak.classList.remove('speaking'); };
					window.speechSynthesis.speak(utterance);
				}
			});
		});
	}

	if (modalClose) modalClose.addEventListener('click', closeModal);
	if (modal) {
		modal.addEventListener('click', function (e) {
			if (e.target === modal) closeModal();
		});
	}
	document.addEventListener('keydown', function (e) {
		if (e.key === 'Escape' && modal && modal.classList.contains('active')) {
			closeModal();
		}
	});

	// 초기 렌더링: 학습 진행도 로드 후 코스 목록 표시
	loadProgress();
	renderCourseGrid();

	console.log(
		'%c◆ NEONBLASTER %c— Welcome to the neon zone!',
		'font-size:20px;font-weight:bold;color:#00f0ff;text-shadow:0 0 10px #00f0ff;',
		'font-size:14px;color:#ff0080;'
	);
})();
