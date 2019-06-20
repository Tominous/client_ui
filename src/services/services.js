import Http from './http';

export default class Services {
    static onload() {
        return Http.get(`data`);
    }

    static createNewKey(keyInfo) {
        return Http.put(`key`, keyInfo);
    }

    static deleteKey(keyInfo) {
        return Http.delete('key', keyInfo);
    }

    static createAccount(accountInfo) {
        return Http.post('account', accountInfo);
    }

    static storeContract(contractInfo) {
        return Http.put('contract', contractInfo);
    }

    static deleteContract(contractInfo) {
        return Http.delete('contract', contractInfo);
    }

    static deployContract(contractInfo) {
        return Http.post('contract', contractInfo);
    }

    static getQuery(data) {
        return Http.get('query', data);
    }
}