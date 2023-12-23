<template>
	<div class="simonGameWrap">
		<div class="simonCircleWrap"
			:class="{
				'beingHighlighted': isHighlighting,
				'gameNotOn': !isGameOn
			}"
		>
			<div v-for="sector in sectors" :key="sector.id"
				:class="{
					[sector.class]: true,
					'sector_highlighted': sector.isHighlighted
				}"
				@click="handleSectorClick(sector.id)"
			>
			</div>
		</div>
		<div class="infoAndControls">
			<p v-if="!isUserFail"
				class="roundNumber">
				{{languagesLocales.round}}: {{roundNumber}}
			</p>
			<div @click="startTheGame">
				<Button v-if="!isGameOn"
					type="button"
					filled
					:label="languagesLocales.startTheGameButtonLabel"/>
			</div>
			<p v-if="isUserFail"
				class="lossAlert">
				{{languagesLocales.youLostAlert}}
			</p>
			<div class="setLevelButtons">
				<p class="levelLabel">Уровень сложности </p>
				<RadioInput
					flex_column
					:disabled="isHighlighting"
					:name="levelButtons.name"
					:buttons="levelButtons.buttons"
					:defaultValue="levelButtons.value"
					@update-input-data="setLevel"
				/>
			</div>
		</div>
	</div>
</template>

<script>
import audio_0 from '@sound/0.ogg'
import audio_1 from '@sound/1.ogg'
import audio_2 from '@sound/2.ogg'
import audio_3 from '@sound/3.ogg'

import Button from '@components/Button'
import RadioInput from '@components/RadioInput'
import Swal from 'sweetalert2'

export default {
	name: 'SimonGame',
	components: {
		Button,
		RadioInput
	},
	data() {
		return {
			language: 'ru',
			languageButtons: {
				name: 'language',
				value: 'ru',
				buttons: [
					{
						name: 'ru',
						nameLocale: 'Русский'
					},
					{
						name: 'en',
						nameLocale: 'English'
					}
				]
			},
			sectorsInit: [
				{
					id: 0,
					class: 'sector sector_first',
					isHighlighted: false
				},
				{
					id: 1,
					class: 'sector sector_second',
					isHighlighted: false
				},
				{
					id: 2,
					class: 'sector sector_third',
					isHighlighted: false
				},
				{
					id: 3,
					class: 'sector sector_fourth',
					isHighlighted: false
				},
			],
			roundNumber: 0,
			level: 'easy',
			isGameOn: false,
			isUserFail: false,
			isHighlighting: false,
			audiosArray: [
				audio_0,
				audio_1,
				audio_2,
				audio_3
			]
		}
	},
	computed: {
		languagesLocales() {
			const {languageButtons, roundNumber} = this;
			switch(languageButtons.value) { //try [languageButtons.value]: language
				case 'ru': return {
					round: 'Раунд',
					startTheGameButtonLabel: 'Начать новую игру',
					youLostAlert: `Вы проиграли в ${roundNumber} раунде`,
					endGameAlert: `Игра окончена!`,
					tryLostRoundButtonLabel: 'Попробовать раунд ещё раз',
					repeatHighlightButtonLabel: 'Повторить последовательность',
					levels: {
						easy: 'Легкий',
						medium: 'Средний',
						hard: 'Сложный'
					},
				}
				case 'en': return {
					round: 'Round',
					startTheGameButtonLabel: 'Start new game',
					youLostAlert: `You lost in ${roundNumber} round`,
					endGameAlert: `Game over!`,
					tryLostRoundButtonLabel: 'Try lost round again',
					repeatHighlightButtonLabel: 'Repeat highlight',
					levels: {
						easy: 'Easy',
						medium: 'Medium',
						hard: 'Complex'
					},
				}
				default: return {
					round: 'Раунд',
					startTheGameButtonLabel: 'Начать новую игру',
					youLostAlert: `Вы проиграли в ${roundNumber} раунде`,
					endGameAlert: `Игра окончена!`,
					tryLostRoundButtonLabel: 'Попробовать раунд ещё раз',
					repeatHighlightButtonLabel: 'Повторить последовательность',
					levels: {
						easy: 'Легкий',
						medium: 'Средний',
						hard: 'Сложный'
					},
				}
			}
		},
		levelButtons() {
			return {
				name: 'level',
				value: 'easy',
				buttons: Object.entries(this.languagesLocales.levels).map(level => {
				const [name, nameLocale] = level
				return ({
					name: name,
					nameLocale: nameLocale
				})
			})}
		},
		timeout() {
			switch(this.level) {
				case 'easy': return 1.5
				case 'medium': return 1;
				case 'hard': return 0.4;
				default: return 1.5;
			}
		},
		sectors() {
			return this.sectorsInit.map(sector => {
				return sector
			})
		},
		gameSelectedSectorsArray() {
			const data = []
			for (let i = 0; i < this.roundNumber; i++) {
				data.push(this.getRandomNumber())
			}
			return data;
		},
		userSelectedSectorsArray() {
			return []
		},
	},
	methods: {
		showAlert() {
			Swal.fire({
				text: this.languagesLocales.endGameAlert,
				icon: 'error',
				showCancelButton: false,
				confirmButtonText: this.languagesLocales.startTheGameButtonLabel,
				// Other options...
			}).then((result) => {
				if (result.isConfirmed) {
					// Handle confirmed action
					this.startTheGame();
				}
			});
		},
		setLanguage(value) {
			this.languageButtons.value = value;
		},
		playAudio(index) {
			const audio = new Audio(this.audiosArray[index])
			audio.play()
		},
		getRandomNumber() {
			return Math.floor(Math.random() * Math.floor(this.sectorsInit.length));
		},
		setLevel(value) {
			this.clearUserSelectedSectors();
			this.level = value;
			if (this.isGameOn && !this.isHighlighting) this.highlightSectors();
		},
		setIsGameOn(value) {
			this.isGameOn = value;
		},
		startTheGame() {
			this.clearUserSelectedSectors();
			this.setIsGameOn(true);
			this.roundNumber = 1;
			this.isUserFail = false;
			this.highlightSectors();
		},
		startNextRound() {
			this.clearUserSelectedSectors();
			this.roundNumber++;
			this.highlightSectors();
		},
		setIsHighlighting(value) {
			this.isHighlighting = value;
		},
		highlightSector(value) {
			this.sectors.forEach(sector => {
				if (sector.id === value) {
					this.sectors[sector.id].isHighlighted = true
					this.playAudio(sector.id)
					setTimeout(() => {
						this.sectors[sector.id].isHighlighted = false
					}, this.timeout / 2 * 1000)
				} else this.sectors[sector.id].isHighlighted = false
			})
		},
		highlightSectors() {
			this.setIsHighlighting(true);
			const {timeout,
				gameSelectedSectorsArray,
				highlightSector} = this;
			gameSelectedSectorsArray.forEach((number, index) => {
				setTimeout(() => {
					highlightSector(number)
				}, timeout * 1000 * (index + 1))
			})
			this.setIsHighlighting(false);
			setTimeout(() => {
			}, timeout * 1000 * (gameSelectedSectorsArray.length + 0.6))
		},
		repeatHighlight() {
			if (this.isHighlighting) return;
			this.clearUserSelectedSectors();
			this.highlightSectors();
		},
		setUserSelectedSectors(value) {
			this.userSelectedSectorsArray.push(value)
		},
		clearUserSelectedSectors() {
			this.userSelectedSectorsArray.length = 0;
		},
		setIsUserFail(userSelectedSectorId) {
			const {gameSelectedSectorsArray: gameSelectedArray,
				userSelectedSectorsArray: userSelectedArray} = this;
			if (gameSelectedArray[userSelectedArray.length - 1] !== userSelectedSectorId) {
				this.handleUserFail()
			}
		},
		handleUserFail() {
			this.isUserFail = true;
			this.setIsGameOn(false);
			this.showAlert();
		},
		tryLostRound() {
			this.isUserFail = false;
			this.setIsGameOn(true);
			this.clearUserSelectedSectors();
			this.highlightSectors();
		},
		handleSectorClick(sectorId) {
			const {gameSelectedSectorsArray: gameSelectedArray,
				userSelectedSectorsArray: userSelectedArray,
				isHighlighting, isGameOn,
				playAudio,
				setUserSelectedSectors,
				setIsUserFail,
				startNextRound} = this;
			if (isHighlighting) return;
			playAudio(sectorId)
			if(!isGameOn) return;
			setUserSelectedSectors(sectorId)
			setIsUserFail(sectorId)
			if (!this.isUserFail &&
				gameSelectedArray.length === userSelectedArray.length) {
				startNextRound()
			}
		},
	}
}
</script>

<style lang="scss" scoped>
.simonGameWrap {
	-webkit-tap-highlight-color: rgba(0, 0, 0, 0);
	display: flex;
	flex-wrap: wrap;
	justify-content: center;
	align-items: center;
	gap: 40px;
	.infoAndControls {
		display: flex;
		flex-direction: column;
		row-gap: 14px;
		.levelLabel {
			margin-top: 30px;
			margin-bottom: 10px;
		}
	}
	.simonCircleWrap {
		min-width: 300px;
		max-width: 300px;
		max-height: 300px;
		min-height: 300px;
		position: relative;
		cursor: pointer;
		.sector {
			transition: 0.25s;
			position: absolute;
			border-radius: inherit;
			width: 40%;
			height: 40%;
			opacity: 0.7;
			box-shadow: 0px 0px 10px 5px rgba(0,0,0,0.55);
			&_first {
				width: 100px;
				height: 100px;
				background-color: $firstSector_color;
				left: 0;
				top: 20px;
			}
			&_second {
				width: 100px;
				height: 100px;
				background-color: $secondSector_color;
				right: 30px;
				top: 20px;
			}
			&_third {
				width: 100px;
				height: 100px;
				background-color: $thirdSector_color;
				bottom: 30px;
				right: 30px;
			}
			&_fourth {
				width: 100px;
				height: 100px;
				background-color: $fourthSector_color;
				left: 0;
				bottom: 30px;
			}
			&_highlighted {
				opacity: 1!important;
			}
			&:hover {
				opacity: 1;
				@media (hover: none) {
					opacity: 0.7;
				}
			}
		}
	}
	.beingHighlighted {
		.sector {
			cursor: default;
			&:hover {
				opacity: 0.7;
			}
		}
	}
}
</style>