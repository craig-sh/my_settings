1. Dump the database (from wherever you run kubectl)
kubectl exec -n default one-postgresql-0 -t  -- \
  pg_dump -Fc -U postgres recipes > /tmp/tandoor-dump.sql

2. Copy media files
kubectl cp default/one-tandoor-0:/opt/recipes/mediafiles /tmp/tandoor-media

3. Transfer both to virtnix
scp /tmp/tandoor-dump.sql virtnix:/tmp/
scp -r /tmp/tandoor-media virtnix:/tmp/

3. Pause containers
podman pause tandoor
podman pause tandoornginx

4. On virtnix as conrun — restore database
podman exec -i tandoordb pg_restore --create --clean -v -U tandoor -d recipes <  /tmp/tandoor-dump.sql

5. On virtnix as conrun — restore media files
MEDIA_MOUNT=$(podman volume inspect --format '{{.Mountpoint}}' tandoor-media)
rsync -ah /tmp/tandoor-media/ "$MEDIA_MOUNT/"

6. Unpause containers
podman unpause tandoor;podman restart tandoor
podman unpause tandoornginx;podman restart tandoornginx

6. Restart the app
systemctl --user restart tandoor

7. Disable the kubernetes service and create a redirect. Sample yaml below
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tandoor-redirect
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/permanent-redirect: "https://tandoor.localdomain:9443"
spec:
  ingressClassName: nginx
  rules:
  - host: "tandoor.localdomain"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tandoor-redirect-dummy
            port:
              number: 80
  tls:
  - secretName: nginx-tls-secret
    hosts:
      - '*.localdomain'
---
apiVersion: v1
kind: Service
metadata:
  name: tandoor-redirect-dummy
  namespace: default
spec:
  ports:
  - port: 80
```
