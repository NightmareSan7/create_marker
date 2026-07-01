const $ = id => document.getElementById(id)

const panel = $('panel')
const fType = $('f-type')
const fAction = $('f-action')
const secNPC = $('sec-npc')
const secMark = $('sec-marker')
const secItem = $('sec-item')

function post(name, data) {
	fetch(`https://` + GetParentResourceName() + `/${name}`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(data ?? {})
	})
}

function close() {
	panel.classList.remove('open')
	post('close')
}

fType.addEventListener('change', () => {
	const isNPC = fType.value === 'npc'
	secMark.classList.toggle('hidden', isNPC)
	secNPC.classList.toggle('hidden', !isNPC)
	if (isNPC) secItem.classList.toggle('hidden', fAction.value !== 'giveItem')
})

fAction.addEventListener('change', () => {
	secItem.classList.toggle('hidden', fAction.value !== 'giveItem')
})

$('btn-cancel').addEventListener('click', close)

$('btn-submit').addEventListener('click', () => {
	const type = fType.value
	const label = $('f-label').value.trim() || null
	let payload = { type, label }

	if (type === 'marker') {
		payload.markerType = parseInt($('f-marker-type').value)
		payload.colorIdx   = parseInt($('f-color').value)
	} else {
		const actionType = fAction.value
		const model = $('f-model').value.trim() || null
		if (model && !/^[a-zA-Z0-9_]{1,64}$/.test(model)) { $('f-model').focus(); return }
		payload.model = model
		payload.action = { type: actionType }
		if (actionType === 'giveItem') {
			const item = $('f-item').value.trim()
			if (!item) { $('f-item').focus(); return }
			payload.action.item = item
			payload.action.count = parseInt($('f-count').value) || null
		}
	}

	panel.classList.remove('open')
	post('submit', payload)
})

document.addEventListener('keydown', e => { if (e.key === 'Escape') close() })

window.addEventListener('message', e => {
	if (e.data.action !== 'open') return

	const markerTypeSel = $('f-marker-type')
	markerTypeSel.innerHTML = '';
	(e.data.markerTypes || []).forEach(t => {
		const opt = document.createElement('option')
		opt.value = t.value
		opt.textContent = t.label
		markerTypeSel.appendChild(opt)
	})

	const colorSel = $('f-color')
	colorSel.innerHTML = '';
	(e.data.colors || []).forEach((c, i) => {
		const opt = document.createElement('option')
		opt.value = i + 1
		opt.textContent = c.label
		colorSel.appendChild(opt)
	})

	fAction.innerHTML = '';
	(e.data.actions || []).forEach(a => {
		const opt = document.createElement('option')
		opt.value = a.value
		opt.textContent = a.label
		fAction.appendChild(opt)
	})

	$('f-label').value = ''
	$('f-model').value = ''
	$('f-item').value = ''
	$('f-count').value = '1'
	fType.value = 'marker'
	secMark.classList.remove('hidden')
	secNPC.classList.add('hidden')
	secItem.classList.add('hidden')

	panel.classList.add('open')
	$('f-label').focus()
})
