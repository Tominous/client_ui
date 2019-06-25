const ENDPOINT = 'http://localhost:4567'
export default class Http {
    static get(url) {
    return fetch(`${ENDPOINT}/${url}`, {
            credentials: 'same-origin',
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }

    static post(url, body) {
        return fetch(`${ENDPOINT}/${url}`, {
            method: 'post',
            credentials: 'same-origin',
            body: JSON.stringify(body),
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }

    static put(url, body) {
        return fetch(`${ENDPOINT}/${url}`, {
            method: 'put',
            credentials: 'same-origin',
            body: JSON.stringify(body),
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }

    static delete(url, body) {
        return fetch(`${ENDPOINT}/${url}`, {
            method: 'delete',
            credentials: 'same-origin',
            body: JSON.stringify(body),
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }
}
