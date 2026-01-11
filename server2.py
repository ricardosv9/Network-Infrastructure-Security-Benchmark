from flask import Flask, request, Response 

app = Flask(__name__)

@app.route('/')
def hello():
    # Buscamos la cabecera X-Forwarded-For que añade el proxy
    ip_cliente_real = request.headers.get('X-Forwarded-For', request.remote_addr)
    
    # Imprimimos un log claro en la terminal
    print(f"Servidor 1: Petición recibida. Cliente real (visto por el proxy): {ip_cliente_real}")
    
    # Damos una respuesta única
    response = Response("<h1>Respuesta desde el Servidor 2 </h1>\n") 
    
    
    # Indicamos que la respuesta es pública y puede ser cacheada por 1 hora (3600 segundos)
    response.headers['Cache-Control'] = 'public, max-age=3600'
    
    return response

if __name__ == '__main__':
    # Escucha en todas las IPs (0.0.0.0) en el puerto 8001
    app.run(host='0.0.0.0', port=8002)
