const HelloWorld = artifacts.require("HelloWorld");

contract('HelloWorld', () => {
    it('should return hello world', async () => {
        const inst = await HelloWorld.deployed();
        const result = await inst.hello();

        assert.equal(result, "hello world", "10000 wasn't in the first account");
    });
})