1. Add the following items to your qb-core/shared/items.lua

['shears'] = {['name'] = 'shears', ['label'] = 'Shears', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'shears.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Harvest up some trees!'},
['trowel'] = {['name'] = 'trowel', ['label'] = 'Trowel', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'trowel.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Dig diggy diggy!'},
['leafblower'] = {['name'] = 'leafblower', ['label'] = 'Leaf Blower', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'leafblower.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'I huff and I puff!'},
['dirty_orange'] = {['name'] = 'dirty_orange', ['label'] = 'Dirty Orange', ['weight'] = 100, ['type'] = 'item', ['image'] = 'dirty_orange.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'From an orange tree.'},
['dirty_lettuce'] = {['name'] = 'dirty_lettuce', ['label'] = 'Dirty Lettuce', ['weight'] = 100, ['type'] = 'item', ['image'] = 'dirty_lettuce.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Straight from the mud.'},
['dirty_tomato'] = {['name'] = 'dirty_tomato', ['label'] = 'Dirty Tomato', ['weight'] = 100, ['type'] = 'item', ['image'] = 'dirty_tomato.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Ground vegetables.'},
['dirty_potato'] = {['name'] = 'dirty_potato', ['label'] = 'Dirty Potato', ['weight'] = 100, ['type'] = 'item', ['image'] = 'dirty_potato.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Straight startch!'},
['orange'] = {['name'] = 'orange', ['label'] = 'Orange', ['weight'] = 100, ['type'] = 'item', ['image'] = 'orange.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Cleaned up orange.'},
['lettuce'] = {['name'] = 'lettuce', ['label'] = 'Lettuce', ['weight'] = 100, ['type'] = 'item', ['image'] = 'lettuce.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Showed up lettuce!'},
['tomato'] = {['name'] = 'tomato', ['label'] = 'Tomato', ['weight'] = 100, ['type'] = 'item', ['image'] = 'tomato.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Rinsed off tomato.'},
['potato'] = {['name'] = 'potato', ['label'] = 'Potato', ['weight'] = 100, ['type'] = 'item', ['image'] = 'potato.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Drippin wet potato!'},

2. Copy the images from the /images/ folder to qb-inventory/html/images

3. Add the following job to qb-core/shared/jobs.lua

['farmer'] = {
    label = 'Farmer',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Employee',
            payment = 30
        },
        ['1'] = {
            name = 'Boss',
            payment = 60,
            isboss = true
        },
    },
},

4. OPTIONAL: Add the following job to qb-cityhall/config.lua

["farmer"] = {["label"] = "Farmer", ["isManaged"] = false},