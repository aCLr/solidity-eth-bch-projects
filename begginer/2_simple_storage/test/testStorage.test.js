const Storage = artifacts.require("Storage");

contract('Storage', () => {
    it('should increment 1 time', async () => {
        const inst = await Storage.deployed();
        const initial = (await inst.val.call()).toNumber();

        await inst.increment();

        assert.equal(initial + 1, (await inst.val.call()).toNumber(), "must be incremented 2 times");
    });

    it('should increment 2 times', async () => {
        const inst = await Storage.new();
        const initial = (await inst.val.call()).toNumber();

        await inst.increment();
        await inst.increment();

        assert.equal(initial + 2, (await inst.val.call()).toNumber(), "must be incremented 2 times");
    });

    it('equal 0 on start', async () => {
        const inst = await Storage.new();
        const initial = (await inst.val.call()).toNumber();

        assert.equal(initial, 0, "must be equal 0");
    });

    it('decremented multiple times', async () => {
        const inst = await Storage.new();
        const initial = (await inst.val.call()).toNumber();

        await inst.increment()
        await inst.increment()
        await inst.increment()

        await inst.decrement();
        assert.equal(initial + 2, (await inst.val.call()).toNumber(), "must be equal 2");

        await inst.decrement();
        assert.equal(initial + 1, (await inst.val.call()).toNumber(), "must be equal 1");
    });

    it('reset', async () => {
        const inst = await Storage.new();
        const initial = (await inst.val.call()).toNumber();

        await inst.increment()
        await inst.increment()
        await inst.increment()

        await inst.decrement();
        assert.equal(initial + 2, (await inst.val.call()).toNumber(), "must be equal 2");

        await inst.decrement();
        assert.equal(initial + 1, (await inst.val.call()).toNumber(), "must be equal 1");
    });
})