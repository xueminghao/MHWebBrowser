var bridgeCallPromisesCache = {};

function postBridgeMessage(moduleMethod, moduleMethodParams,callBack) {
    if (moduleMethod == undefined) {
        return;
    }
    var promise = new Promise(function (resolve, reject) {
        var promiseIdentifier = generateBridgeCallUUID();
        bridgeCallPromisesCache[promiseIdentifier] = { "resolve": resolve, "reject": reject };
        window.webkit.messageHandlers.bridgeTunnel.postMessage({
            "BridgeTunnelMessagePromiseIdendifier": promiseIdentifier,
            "BridgeMethodName": moduleMethod,
            "BridgeMethodParams": moduleMethodParams == undefined ? "" : moduleMethodParams,
        });
    });
    promise.then(function (result) { callBack(result) }, function (error) { });
    return promise;
}

function resolveBridgePromise(promiseIdentifier, data) {
    bridgeCallPromisesCache[promiseIdentifier]["resolve"](data);
    delete jsbridgePromises[promiseIdentifier];
}

function rejectBridgePromise(promiseIdentifier, errorInfo) {
    var error = new Error(errorInfo);
    bridgeCallPromisesCache[promiseIdentifier]["reject"](error);
    delete jsbridgePromises[promiseIdentifier];
}

function generateBridgeCallUUID() {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
        s4() + '-' + s4() + s4() + s4();
}
