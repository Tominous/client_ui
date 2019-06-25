export default class Http {
    static get(url) {
    return fetch(`/${url}`, {
            credentials: 'same-origin',
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }

    static post(url, body) {
        return fetch(`/${url}`, {
            method: 'post',
            credentials: 'same-origin',
            body: JSON.stringify(body),
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }

    static put(url, body) {
        return fetch(`/${url}`, {
            method: 'put',
            credentials: 'same-origin',
            body: JSON.stringify(body),
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }

    static delete(url, body) {
        return fetch(`/${url}`, {
            method: 'delete',
            credentials: 'same-origin',
            body: JSON.stringify(body),
            headers: {
                'content-type': 'application/json'
            }
        }).then((res) => res.json())
    }
}
